terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.46.0"
    }
  }
  backend "azurerm" {
  }
}
provider "azurerm" {
  storage_use_azuread = true
  features {}
}