terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.10.0"
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

# Database

resource "azurerm_mssql_server" "default" {
  name                         = "sql-workloadbenchmark"
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

# App

resource "azurerm_service_plan" "default" {
  name                = "plan-workloadbenchmark"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  os_type             = "Linux"
  sku_name            = var.plan_sku_name

}

resource "azurerm_linux_web_app" "default" {
  name                = "app-workloadbenchmark-999"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  service_plan_id     = azurerm_service_plan.default.id
  https_only          = true

  site_config {
    always_on = true

    application_stack {
      docker_image     = "epomatti/workload-benchmarks-python-django"
      docker_image_tag = "latest"
    }
  }

  app_settings = {
    DOCKER_ENABLE_CI           = true
    DOCKER_REGISTRY_SERVER_URL = "https://index.docker.io"
    # COSMOS_PRIMARY_CONNECTION_STRING   = azurerm_cosmosdb_account.default.connection_strings[0]
    WEBSITES_PORT = 8000
  }

}

# resource "azurerm_application_insights" "default" {
#   name                = "appi-benchmark"
#   location            = azurerm_resource_group.default.location
#   resource_group_name = azurerm_resource_group.default.name
#   workspace_id        = azurerm_log_analytics_workspace.default.id
# }

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
