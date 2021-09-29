#############################################################################
# VARIABLES
#############################################################################

variable "resource_group_name" {
  description = "main resource group"
  type        = string
}

variable "vnet_name" {
  description = "main network name"
  type        = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vnet_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_prefixes" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "subnet_names" {
  type    = list(string)
  default = ["web", "database", "genral", "security"]
}