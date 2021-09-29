#############################################################################
# TERRAFORM CONFIG Used Only to stand up backend end tfstate storage
#############################################################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
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

#used to ensure the storage account name is globablly unique
resource "random_integer" "sa_num" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate-backend"
  location = "east us"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "${lower("tfstatebackend")}${random_integer.sa_num.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
