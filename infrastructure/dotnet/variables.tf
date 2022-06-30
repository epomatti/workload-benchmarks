# Resources
variable "location" {
  default = "brazilsouth"
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
  default = "S2"
  type    = string
}


variable "websites_port" {
  default = 80
  type    = number
}

variable "docker_image" {
  default = "epomatti/workload-benchmarks-dotnet"
  type    = string
}
