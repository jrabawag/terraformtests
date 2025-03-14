data "azurerm_client_config" "current" {
}

# RESOURCE GROUPS
module "resource_groups" {
  source   = "../../modulesSEV2/resource_group"
  for_each = { for key, data in var.resource_data : key => data  if length(data.resource_groups) > 0 }
  create   = true
  tags     = local.default_tags
  resource_groups = {
    for key, rg in each.value.resource_groups : rg => {
      name     = "rg-${var.project}-${each.key}-${rg}-${lower(var.environment)}"
      location = local.locations_map[each.key]
    }
  } 
}

# data "azurerm_private_dns_zone" "private_dns_zones" {
#   for_each            = { for key, data in var.resource_data : key => data.priv_dns_zones[0] }
#   name                = each.value
#   resource_group_name = module.resource_groups[each.key].resource_groups["network"].name
# }

# data "azurerm_log_analytics_workspace" "log_analytics" {
#   for_each            = { for key, loga in var.resource_data : key => loga if loga.loga_name != null && loga.loga_rg != null }
#   name                = "log-${var.project}-${each.key}-${each.value.loga_name}-${lower(var.environment)}"
#   resource_group_name = module.resource_groups[each.key].resource_groups[each.value.loga_rg].name
# }

# data "azurerm_key_vault" "keyvault" {
#   for_each            = { for key, kv in var.resource_data : key => kv if kv.kv_name != null && kv.kv_rg != null }
#   name                = "kv${var.shortproject}${each.key}${each.value.kv_name}${lower(var.environment)}" #change
#   resource_group_name = module.resource_groups[each.key].resource_groups[each.value.kv_rg].name
# }

# data "azurerm_firewall" "firewall" {
#   for_each            = { for key, fw in var.resource_data : key => fw if fw.fw_name != null && fw.fw_rg != null }
#   name                = "afw-${var.project}-${each.key}-${each.value.fw_name}-${lower(var.environment)}"
#   resource_group_name = module.resource_groups[each.key].resource_groups[each.value.fw_rg].name
# }



resource "azurerm_private_dns_zone" "private_dns_zones" {
  for_each            = { for key, data in var.resource_data : key => data.priv_dns_zones[0] }
  name                = each.value
  resource_group_name = module.resource_groups[each.key].resource_groups["network"].name
}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  for_each            = { for key, loga in var.resource_data : key => loga if loga.loga_name != null && loga.loga_rg != null }
  name                = "log-${var.project}-${each.key}-${each.value.loga_name}-${lower(var.environment)}"
  resource_group_name = module.resource_groups[each.key].resource_groups[each.value.loga_rg].name
  location            = local.locations_map[each.key]
  sku                 = "PerGB2018"  # Adding a SKU field as it is required for creating the resource
  retention_in_days   = 30           # Setting retention period (example)
}

resource "azurerm_key_vault" "keyvault" {
  for_each            = { for key, kv in var.resource_data : key => kv if kv.kv_name != null && kv.kv_rg != null }
  name                = "kv${var.shortproject}${each.key}${each.value.kv_name}${lower(var.environment)}"
  resource_group_name = module.resource_groups[each.key].resource_groups[each.value.kv_rg].name
  location            = local.locations_map[each.key]
  sku_name            =  "standard"
  tenant_id           = var.aad_tenant_id  # Adding tenant ID as it is required for creating the resource
}

resource "azurerm_firewall" "firewall" {
  for_each            = { for key, fw in var.resource_data : key => fw if fw.fw_name != null && fw.fw_rg != null }
  name                = "afw-${var.project}-${each.key}-${each.value.fw_name}-${lower(var.environment)}"
  resource_group_name = module.resource_groups[each.key].resource_groups[each.value.fw_rg].name
  location            = local.locations_map[each.key]
  sku_name            = "AZFW_VNet"    # Adding SKU name as it is required for creating the resource
  sku_tier            = "Standard"
}

module "network" {
  for_each                   = var.network_data
  source                     = "../../modulesSEV2/virtual_network"
  create_vnet                = each.value.existing ? false : true
  create_subnet              = each.value.existing ? false : true 
  resource_group_name        = "rg-${var.project}-${each.key}-${each.value.rg_name}-${lower(var.environment)}"
  location                   = local.locations_map[each.key]
  vnet_name                  = length(each.value.vnet_name) > 0 ? "vnet-${var.project}-${each.key}-${each.value.vnet_name}-${lower(var.environment)}" : "vnet-${var.project}-${each.key}-${lower(var.environment)}"
  vnet_address_space = each.value.existing ? coalesce(try(each.value.vnet_address, []), []) : ["10.0.0.0/16"]
  log_analytics_workspace_id = contains(keys(azurerm_log_analytics_workspace.log_analytics), each.key) ? azurerm_log_analytics_workspace.log_analytics[each.key].id : azurerm_log_analytics_workspace.log_analytics[var.default_region].id
  subnets = {
    for subnet_key, subnet_value in each.value.subnets : subnet_key => {
      name                                          = length(subnet_value.name) > 0 ? "${var.project}${subnet_value.name}Subnet" : null
      address_prefixes                              = coalesce(subnet_value.address_prefixes, [])
      private_endpoint_network_policies             = subnet_value.private_endpoint_network_policies
      private_link_service_network_policies_enabled = subnet_value.private_link_service_network_policies_enabled
    }
  }
}






