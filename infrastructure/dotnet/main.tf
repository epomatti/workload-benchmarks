terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.12.0"
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

module "workload" {

  source = "../workload"

  # resources
  location = var.location
  app      = var.app

  # sqlserver
  mssql_max_size_gb    = var.mssql_max_size_gb
  mssql_read_scale     = var.mssql_read_scale
  mssql_sku_name       = var.mssql_sku_name
  mssql_zone_redundant = var.mssql_zone_redundant

  # app
  plan_sku_name           = var.plan_sku_name
  autoscale_default_nodes = var.autoscale_default_nodes
  autoscale_minimum_nodes = var.autoscale_minimum_nodes
  autoscale_maximum_nodes = var.autoscale_maximum_nodes
  websites_port           = var.websites_port
  docker_image            = var.docker_image
  health_check_path       = var.health_check_path
}
