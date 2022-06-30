# Resources

variable "location" {
  type = string
}

variable "app" {
  type = string
}

# Database

variable "mssql_max_size_gb" {
  type = number
}

variable "mssql_read_scale" {
  type = bool
}

variable "mssql_sku_name" {
  type = string
}

variable "mssql_zone_redundant" {
  type = bool
}


# Plan
variable "plan_sku_name" {
  type = string
}

variable "websites_port" {
  type = number
}

variable "docker_image" {
  type = string
}
