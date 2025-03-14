terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

  required_version = ">= 0.14.9"
}

locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = merge(var.tags, local.module_tag)
}

resource "azurerm_resource_group" "this" {
  for_each = { for resource_group in var.resource_groups : resource_group.name => resource_group }

  name     = each.key
  location = each.value.location
  tags     = var.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
