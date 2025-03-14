terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.46.0"
    }
  }
  # backend "azurerm" {
  # }
  backend "local" {
    path = "terraform.tfstate"
  }
}
provider "azurerm" {
  # storage_use_azuread = true
  features {}
}

#> $env:ARM_SUBSCRIPTION_ID="67e3289f-ecc9-44ab-840b-20eb34d81fd6"  