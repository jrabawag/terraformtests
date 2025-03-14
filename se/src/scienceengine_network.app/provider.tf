terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.1.0"
    }

  }
  backend "azurerm" {
  }
}
provider "azurerm" {
  storage_use_azuread = true
  features {}
}
