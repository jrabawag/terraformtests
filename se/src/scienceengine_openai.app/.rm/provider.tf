terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.46.0"
    }
    # azuread = {
    #   source = "hashicorp/azuread"
    #   version = "2.49.1"
    # }
  }
  backend "azurerm" {
  }
}
provider "azurerm" {
  storage_use_azuread = true
  features {}
}

# provider "azuread" {
# }