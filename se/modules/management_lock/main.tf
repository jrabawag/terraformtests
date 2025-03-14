terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  required_version = ">= 0.14.9"
}

resource "azurerm_management_lock" "resource_lock" {
  name       = var.name
  scope      = var.scope
  lock_level = var.lock_level
  notes      = var.notes
}