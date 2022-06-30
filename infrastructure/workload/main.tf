
locals {
  affix          = "benchmark-${var.app}"
  mssql_username = "4dm1n157r470r"
  mssql_password = "4-v3ry-53cr37-p455w0rd"
}

# Group

resource "azurerm_resource_group" "default" {
  name     = "rg-${local.affix}"
  location = var.location
}

# Log Analytics

resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-${local.affix}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Network

resource "azurerm_virtual_network" "default" {
  name                = "vnet-${local.affix}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "mssql" {
  name                 = "mssql-subnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.10.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.20.0/24"]
  service_endpoints    = ["Microsoft.Sql"]

  delegation {
    name = "delegation"
    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_subnet" "vm" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.90.0/24"]
  service_endpoints    = ["Microsoft.Web"]
}

# Database

resource "azurerm_mssql_server" "default" {
  name                         = "sql-${local.affix}999"
  resource_group_name          = azurerm_resource_group.default.name
  location                     = azurerm_resource_group.default.location
  version                      = "12.0"
  administrator_login          = local.mssql_username
  administrator_login_password = local.mssql_password
}

resource "azurerm_mssql_database" "default" {
  name           = "sqldb-${local.affix}"
  server_id      = azurerm_mssql_server.default.id
  max_size_gb    = var.mssql_max_size_gb
  read_scale     = var.mssql_read_scale
  sku_name       = var.mssql_sku_name
  zone_redundant = var.mssql_zone_redundant

  lifecycle {
    ignore_changes = [
      max_size_gb, sku_name
    ]
  }
}

resource "azurerm_mssql_virtual_network_rule" "sql" {
  name      = "sql-vnet-rule"
  server_id = azurerm_mssql_server.default.id
  subnet_id = azurerm_subnet.mssql.id
}

resource "azurerm_mssql_virtual_network_rule" "app" {
  name      = "app-vnet-rule"
  server_id = azurerm_mssql_server.default.id
  subnet_id = azurerm_subnet.app.id
}

# Insights

resource "azurerm_application_insights" "default" {
  name                = "appi-${local.affix}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  workspace_id        = azurerm_log_analytics_workspace.default.id
  application_type    = "other"
}

# App

resource "azurerm_service_plan" "default" {
  name                = "plan-${local.affix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  os_type             = "Linux"
  sku_name            = var.plan_sku_name

  lifecycle {
    ignore_changes = [
      sku_name
    ]
  }
}

resource "azurerm_linux_web_app" "default" {
  name                = "app-${local.affix}999"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  service_plan_id     = azurerm_service_plan.default.id
  https_only          = true

  # TODO: Health Check

  site_config {
    always_on = true

    application_stack {
      docker_image     = var.docker_image
      docker_image_tag = "latest"
    }
  }

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.default.connection_string
    DOCKER_ENABLE_CI                      = true
    DOCKER_REGISTRY_SERVER_URL            = "https://index.docker.io"
    WEBSITES_PORT                         = var.websites_port
    DB_NAME                               = azurerm_mssql_database.default.name
    DB_SERVER                             = azurerm_mssql_server.default.fully_qualified_domain_name
    DB_PORT                               = 1433
    DB_USER                               = local.mssql_username
    DB_PASSWORD                           = local.mssql_password
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "default" {
  app_service_id = azurerm_linux_web_app.default.id
  subnet_id      = azurerm_subnet.app.id
}

resource "azurerm_monitor_diagnostic_setting" "plan" {
  name                       = "Plan Diagnostics"
  target_resource_id         = azurerm_service_plan.default.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.default.id

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      days    = 7
      enabled = true
    }
  }
}


resource "azurerm_monitor_diagnostic_setting" "app" {
  name                       = "Application Diagnostics"
  target_resource_id         = azurerm_linux_web_app.default.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.default.id

  log {
    category = "AppServiceHTTPLogs"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  log {
    category = "AppServiceConsoleLogs"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  log {
    category = "AppServiceAppLogs"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  log {
    category = "AppServiceAuditLogs"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  log {
    category = "AppServiceIPSecAuditLogs"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  log {
    category = "AppServicePlatformLogs"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
}

# Load Testing VM

resource "azurerm_network_security_group" "default" {
  name                = "nsg-${local.affix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "default" {
  name                = "pip-${local.affix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "default" {
  name                = "nic-${local.affix}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  ip_configuration {
    name                          = "subnet-config"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.default.id
  }
}

resource "azurerm_network_interface_security_group_association" "default" {
  network_interface_id      = azurerm_network_interface.default.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_linux_virtual_machine" "default" {
  name                  = "vm-${local.affix}"
  resource_group_name   = azurerm_resource_group.default.name
  location              = azurerm_resource_group.default.location
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.default.id]
  custom_data           = filebase64("${path.module}/cloud-init.sh")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
