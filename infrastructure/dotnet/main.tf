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

# Locals

locals {
  app = "dotnet"
}

module "workload" {

  source = "../workload"

  # resources
  location = var.location
  app      = local.app

  # sqlserver
  mssql_max_size_gb    = var.mssql_max_size_gb
  mssql_read_scale     = var.mssql_read_scale
  mssql_sku_name       = var.mssql_sku_name
  mssql_zone_redundant = var.mssql_zone_redundant

  # app
  plan_sku_name = var.plan_sku_name
  websites_port = var.websites_port
  docker_image  = var.docker_image
}
