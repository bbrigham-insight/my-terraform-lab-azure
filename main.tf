#############################################################################
# TERRAFORM CONFIG
#############################################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}
# This is a bootstrap file to provision backend storage in Azure for Terraform State Files
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-backend"
    storage_account_name = "tfstatebackend24068"
    container_name       = "content"
    key                  = "terraform.tfstate"
  }
}
#############################################################################
# PROVIDERS
#############################################################################

provider "azurerm" {
  features {}
}

#############################################################################
# RESOURCES
#############################################################################

resource "azurerm_resource_group" "vnet_main" {
  name     = var.resource_group_name
  location = var.location
}

module "vnet-main" {
  source              = "Azure/vnet/azurerm"
  version             = "~> 2.0"
  resource_group_name = azurerm_resource_group.vnet_main.name
  vnet_name           = var.vnet_name
  address_space       = [var.vnet_cidr_range]
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  nsg_ids             = {}

  tags = {
    environment = "dev"
    costcenter  = "it"
  }

  depends_on = [azurerm_resource_group.vnet_main]
}

module "network-security-group" {
  source                = "Azure/network-security-group/azurerm"
  resource_group_name   = var.resource_group_name
  location              = var.location # Optional; if not provided, will use Resource Group location
  security_group_name   = "nsg-base-rules-all"
  source_address_prefixes = var.subnet_prefixes
  predefined_rules = [
    {
      name     = "SSH"
      priority = "500"
    },
    {
      name              = "LDAP"
      source_port_range = "1024-1026"
    }
  ]

  custom_rules = [
    {
      name                   = "myssh"
      priority               = 201
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "tcp"
      source_port_range      = "*"
      destination_port_range = "22"
      source_address_prefixes  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
      description            = "description-myssh"
    },
    {
      name                    = "myhttp"
      priority                = 200
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "tcp"
      source_port_range       = "*"
      destination_port_range  = "8080"
      source_address_prefixe  = "10.0.3.0/24"
      description             = "description-http"
    },
  ]

  tags = {
    environment = "dev"
    costcenter  = "it"
  }

  depends_on = [azurerm_resource_group.vnet_main]
}

resource "azurerm_subnet_network_security_group_association" "nsg-to-vnet" {
  count = length(var.subnet_names)
  subnet_id                 = element(module.vnet-main.vnet_subnets, count.index)
  network_security_group_id = module.network-security-group.network_security_group_id
}
#############################################################################
# OUTPUTS
#############################################################################

output "vnet_subnets" {
  value = module.vnet-main.vnet_id
}

output "nsg_id" {
    value = module.network-security-group.network_security_group_id
}