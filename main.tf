terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}


module "devone" {
  source                       = "./modules"
  prefix                       = "devone"
  location                     = "eastus2"
  default_vnet_address_space   = ["10.0.0.0/16"]
  default_subnet_address_space = ["10.0.1.0/24"]
}

module "devtwo" {
  source                       = "./modules"
  prefix                       = "devtwo"
  location                     = "eastus"
  default_vnet_address_space   = ["10.1.0.0/16"]
  default_subnet_address_space = ["10.1.1.0/24"]
}
