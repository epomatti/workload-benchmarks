# Resources
variable "location" {
  default = "brazilsouth"
  type    = string
}

variable "app" {
  default = "dotnet"
  type    = string
}

# Database

variable "mssql_max_size_gb" {
  default = 1
  type    = number
}

variable "mssql_read_scale" {
  default = false
  type    = bool
}

variable "mssql_sku_name" {
  default = "S0"
  type    = string
}

variable "mssql_zone_redundant" {
  default = false
  type    = bool
}


# App
variable "plan_sku_name" {
  default = "S1"
  type    = string
}

variable "autoscale_default_nodes" {
  default = 1
  type    = number
}

variable "autoscale_minimum_nodes" {
  default = 1
  type    = number
}

variable "autoscale_maximum_nodes" {
  default = 1
  type    = number
}

variable "websites_port" {
  default = 80
  type    = number
}

variable "docker_image" {
  default = "epomatti/workload-benchmarks-dotnet"
  type    = string
}

variable "health_check_path" {
  default = "/healthz"
  type    = string
}
