terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.1.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "0.7.0"
    }
  }
  backend "azurerm" {
  }
}
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# provider "azuredevops" {
#   org_service_url       = "https://dev.azure.com/novonordiskit/"
#   personal_access_token = var.adoPAT
# }

provider "azurerm" {
  features {}
  subscription_id                 = "3593555d-bd97-4ce3-9863-aaee8919c3cd"
  alias                           = "gallery"
  resource_provider_registrations = "none"
}