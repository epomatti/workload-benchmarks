
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
      sku_name, worker_count
    ]
  }
}

resource "azurerm_linux_web_app" "default" {
  name                = "app-${local.affix}999"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  service_plan_id     = azurerm_service_plan.default.id
  https_only          = true

  site_config {
    always_on         = true
    health_check_path = var.health_check_path

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

resource "azurerm_monitor_autoscale_setting" "default" {
  name                = "AppAutoscaling"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  target_resource_id  = azurerm_service_plan.default.id

  profile {
    name = "default"

    capacity {
      default = var.autoscale_default_nodes
      minimum = var.autoscale_minimum_nodes
      maximum = var.autoscale_maximum_nodes
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.default.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 90
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.default.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 40
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
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

  # log {
  #   category = "AppServiceAntivirusScanAuditLogs"
  #   enabled  = false

  #   retention_policy {
  #     days    = 0
  #     enabled = false
  #   }
  # }

  # log {
  #   category = "AppServiceFileAuditLogs"
  #   enabled  = false

  #   retention_policy {
  #     days    = 0
  #     enabled = false
  #   }
  # }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
}
