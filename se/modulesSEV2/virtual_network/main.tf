locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = merge(var.tags, local.module_tag)

  vnet_cidr = var.create_vnet ? tolist(azurerm_virtual_network.vnet[0].address_space)[0] : tolist(data.azurerm_virtual_network.vnet[0].address_space)[0]
}

resource "azurerm_virtual_network" "vnet" {
  count               = var.create_vnet ? 1 : 0
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space
  tags                = var.tags
}

data "azurerm_virtual_network" "vnet" {
  count               = var.create_vnet ? 0 : 1
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  for_each = var.create_subnet && length(var.subnets) > 0 ? { for key, subnet in var.subnets : key => subnet } : {}

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.create_vnet ? azurerm_virtual_network.vnet[0].name : data.azurerm_virtual_network.vnet[0].name

  address_prefixes = each.value.address_prefixes != null && length(each.value.address_prefixes) > 0 ? each.value.address_prefixes : [cidrsubnet(local.vnet_cidr, 4, index(keys(var.subnets), each.key))]
  service_endpoints                             = lookup(each.value, "service_endpoints", [])
  private_endpoint_network_policies             = lookup(each.value, "private_endpoint_network_policies", null)
  private_link_service_network_policies_enabled = lookup(each.value, "private_link_service_network_policies_enabled", null)

  dynamic "delegation" {
    for_each = lookup(each.value, "service_delegations", [])
    content {
      name = "${each.key}-delegation-${delegation.value}"
      service_delegation {
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        name    = delegation.value
      }
    }
  }
}

# resource "azurerm_subnet" "subnet" {
#   for_each = var.create_subnet && length(var.subnets) > 0 ? { for key, subnet in var.subnets : key => subnet } : {}

#   name                                          = each.value.name
#   resource_group_name                           = var.resource_group_name
#   virtual_network_name                          = var.create_vnet ? azurerm_virtual_network.vnet[0].name : data.azurerm_virtual_network.vnet[0].name
#   address_prefixes                              = each.value.address_prefixes
#   service_endpoints                             = each.value.service_endpoints
#   private_endpoint_network_policies             = each.value.private_endpoint_network_policies
#   private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

#   dynamic "delegation" {
#     for_each = each.value.service_delegations != null ? each.value.service_delegations : []
#     content {
#       name = "${each.key}-delegation-${delegation.value}"
#       service_delegation {
#         actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
#         name    = delegation.value
#       }
#     }
#   }
# }

data "azurerm_subnet" "subnet" {
  for_each = !var.create_subnet && length(var.subnets) > 0 ? { for key, subnet in var.subnets : key => subnet } : {}

  name                 = each.value.name
  virtual_network_name = var.create_vnet ? azurerm_virtual_network.vnet[0].name : data.azurerm_virtual_network.vnet[0].name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  for_each                   = var.create_vnet ? { for k, v in azurerm_virtual_network.vnet : k => v.id } : { for k, v in data.azurerm_virtual_network.vnet : k => v.id }
  name                       = "DiagnosticsSettings"
  target_resource_id         = each.value
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "VMProtectionAlerts"
  }

  metric {
    category = "AllMetrics"
  }
}