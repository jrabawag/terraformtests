terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  required_version = ">= 0.14.9"
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  count = var.create_vnet ? 1 : 0

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name

  count = var.create_vnet ? 0 : 1
}


resource "azurerm_subnet" "subnet" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                                          = each.key
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = var.vnet_name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = each.value.service_endpoints
  private_endpoint_network_policies             = each.value.private_endpoint_network_policies
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  # dynamic "delegation" {
  #   for_each = lookup(each.value, "service_delegations", [])

  #   content {
  #     name = "${each.key}-delegation-${delegation.value}"
  #     service_delegation {
  #       actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  #       name    = delegation.value
  #     }
  #   }
  # }
  dynamic "delegation" {
    for_each = each.value.service_delegations != null ? each.value.service_delegations : []
    # for_each = lookup(each.value, "service_delegations", [])
    content {
      name = "${each.key}-delegation-${delegation.value}"
      service_delegation {
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        name    = delegation.value
      }
    }
}

   depends_on = [azurerm_virtual_network.vnet]
  # lifecycle {
  #   ignore_changes = [
  #     delegation
  #   ]
  # }
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = var.create_vnet ? azurerm_virtual_network.vnet[0].id : data.azurerm_virtual_network.vnet[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "VMProtectionAlerts"
  }

  metric {
    category = "AllMetrics"
  }
}