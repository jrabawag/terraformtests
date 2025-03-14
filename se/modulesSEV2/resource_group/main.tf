terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

  required_version = ">= 0.14.9"
}

locals {
  module_tag = { "module" = basename(abspath(path.module))}
  tags = merge(var.tags, local.module_tag)
}

# Create Resource Groups
resource "azurerm_resource_group" "this" {
  for_each = var.create ? var.resource_groups : {}
  name     = each.value.name
  location = each.value.location
  tags     = local.tags
}

data "azurerm_resource_group" "this" {
  for_each = !var.create ? var.resource_groups : {}
  name     = each.value.name
}

# # Reference Existing Resource Groups
# data "azurerm_resource_group" "this" {
#   for_each = !var.resource_groups.create ? { for resource_group in var.resource_groups : resource_group.name => resource_group } : {}

#   name = each.value.name
# }

# # Create Resource Groups
# resource "azurerm_resource_group" "this" {
#   for_each = { for rg in var.resource_groups : rg.name => rg }
#   name     = each.value.name
#   location = each.value.location
# }
# data "azurerm_resource_group" "this" {
#   for_each = { for resource_group in var.resource_groups : resource_group.name => resource_group if var.create == false }
#   name = each.value.name
# }

# # Create Resource Groups
# resource "azurerm_resource_group" "this" {
#   for_each = var.create ? { for rg in var.resource_groups : rg.name => rg } : {}
#   name     = each.value.name
#   location = each.value.location
#   tags     = local.tags
# }


# data "azurerm_resource_group" "this" {
#   for_each = !var.create ? { for rg in var.resource_groups : rg.name => rg } : {}
#   name     = each.value.name
# }