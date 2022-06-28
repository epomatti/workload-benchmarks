terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.11.0"
    }
  }
  backend "local" {
    path = "./.workspace/terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Group

resource "azurerm_resource_group" "default" {
  name     = var.rg_name
  location = var.location
}

# Log Analytics

resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-benchmark"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Network

resource "azurerm_virtual_network" "default" {
  name                = "vnet-benchmark"
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
  name                         = "sql-benchmark999"
  resource_group_name          = azurerm_resource_group.default.name
  location                     = azurerm_resource_group.default.location
  version                      = var.mssql_version
  administrator_login          = var.mssql_login
  administrator_login_password = var.mssql_password
}

resource "azurerm_mssql_database" "default" {
  name           = "sqldb-benchmark"
  server_id      = azurerm_mssql_server.default.id
  max_size_gb    = var.mssql_max_size_gb
  read_scale     = var.mssql_read_scale
  sku_name       = var.mssql_sku_name
  zone_redundant = var.mssql_zone_redundant
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
  name                = "appi-benchmark"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  workspace_id        = azurerm_log_analytics_workspace.default.id
  application_type    = "other"
}

# App

resource "azurerm_service_plan" "default" {
  name                = "plan-benchmark"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  os_type             = "Linux"
  sku_name            = var.plan_sku_name

}

resource "azurerm_linux_web_app" "default" {
  name                = "app-benchmark999"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  service_plan_id     = azurerm_service_plan.default.id
  https_only          = true

  # TODO: Health Check

  site_config {
    always_on = true

    application_stack {
      docker_image     = "epomatti/workload-benchmarks-python-django"
      docker_image_tag = "latest"
    }
  }

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.default.connection_string
    DOCKER_ENABLE_CI                      = true
    DOCKER_REGISTRY_SERVER_URL            = "https://index.docker.io"
    WEBSITES_PORT                         = 8000
    DB_NAME                               = azurerm_mssql_database.default.name
    DB_SERVER                             = azurerm_mssql_server.default.fully_qualified_domain_name
    DB_PORT                               = 1433
    DB_USER                               = var.mssql_login
    DB_PASSWORD                           = var.mssql_password
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

resource "azurerm_network_interface" "default" {
  name                = "nic-benchmark"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  ip_configuration {
    name                          = "subnet-config"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "default" {
  name                  = "vm-bechmark"
  resource_group_name   = azurerm_resource_group.default.name
  location              = azurerm_resource_group.default.location
  network_interface_ids = [azurerm_network_interface.default.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "22.04.202205060"
  }

  storage_os_disk {
    name              = "disk-vm-benchmark"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = "jumpbox"
    admin_username = "azureuser"
    # admin_password = var.password
    custom_data    = filebase64("${path.module}/cloud-init.sh")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}
