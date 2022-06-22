variable "location" {
  default = "brazilsouth"
  type    = string
}

variable "rg_name" {
  default = "rg-benchmark"
  type    = string
}

# Database

variable "mssql_version" {
  default = "12.0"
  type    = string
}

variable "mssql_login" {
  default = "4dm1n157r470r"
  type    = string
}

variable "mssql_password" {
  default   = "4-v3ry-53cr37-p455w0rd"
  type      = string
  sensitive = true
}

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


# Plan

variable "plan_sku_name" {
  default = "S1"
  type    = string
}
