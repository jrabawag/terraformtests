terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.13.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  backend "local" {
    path = "./terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
  subscription_id = "67e3289f-ecc9-44ab-840b-20eb34d81fd6"
}
provider "azapi" {
}
