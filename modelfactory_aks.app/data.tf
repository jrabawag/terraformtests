data "azurerm_client_config" "current" {
}

# VNET
resource "azurerm_virtual_network" "vnet" {
  for_each            = { for key, vnet in var.data.network : key => vnet }
  name                = "vnet-${var.project}-${each.key}-${lower(var.environment)}"
  resource_group_name = "rg-${var.project}-${each.key}-${each.value.resource_group}-${lower(var.environment)}"
  location            = local.locations_map[each.key]
  address_space       = ["10.3.0.0/19"]
}
# data "azurerm_virtual_network" "network" {
#   for_each = var.data.network
#   name     ="vnet-${var.project}-${each.key}-${lower(var.environment)}"
#   resource_group_name = "rg-${var.project}-${each.key}-network-${lower(var.environment)}"
# }


# Keyvaults
resource "azurerm_key_vault" "keyvault" {
  #${each.key}${each.value.name}
  for_each            = { for key, kv in var.data.keyvault : key => kv } 
  name                = "kv${var.project}${lower(var.environment)}"
  resource_group_name = "rg-${var.project}-${each.key}-${each.value.resource_group}-${lower(var.environment)}"
  location            = local.locations_map[each.key]
  tenant_id           = var.aad_tenant_id
  sku_name            = "premium"
}

# data "azurerm_key_vault" "keyvault" {
#   for_each            = var.data.keyvault
#   name                = "kv${var.project}${each.key}${var.config.keyvault.name}${lower(var.environment)}"
#   resource_group_name = each.value.resource_group
# }


# Log analytics
resource "azurerm_log_analytics_workspace" "log_analytics" {
  for_each            = { for key, log in var.data.log_analytics : key => log } 
  name                = "log-${var.project}-${each.key}-${each.value.name}-${lower(var.environment)}"
  resource_group_name = "rg-${var.project}-${each.key}-${each.value.resource_group}-${lower(var.environment)}"
  location            = local.locations_map[each.key]
}

# data "azurerm_log_analytics_workspace" "log_analytics" {
#   for_each            = var.data.log_analytics
#   name                = each.value.name
#   resource_group_name = each.value.resource_group
# }


































# resource "azurerm_resource_group" "network" {
#   for_each = var.data.network
#   name     = each.value.resource_group
#   location = "UK South" # Modify based on region
# }

# resource "azurerm_resource_group" "identities" {
#   for_each = var.data.identities
#   name     = each.value.resource_group
#   location = "UK South"
# }

# resource "azurerm_key_vault" "keyvault" {
#   for_each            = var.data.keyvault
#   name                = "kv-${each.value.name}"
#   location            = "UK South"
#   resource_group_name = each.value.resource_group
#   tenant_id           = "your-tenant-id"

#   sku_name = "standard"
# }

# resource "azurerm_log_analytics_workspace" "log_analytics" {
#   for_each            = var.data.log_analytics
#   name                = each.value.name
#   location            = "UK South"
#   resource_group_name = each.value.resource_group
#   sku                 = "PerGB2018"
# }
