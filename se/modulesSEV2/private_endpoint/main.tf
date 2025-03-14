terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

  required_version = ">= 0.14.9"
}

# resource "azurerm_private_endpoint" "private_endpoint" {
#   name                = var.name
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = var.subnet_id
#   tags                = var.tags

#   private_service_connection {
#     name                           = "${var.name}Connection"
#     private_connection_resource_id = var.private_connection_resource_id
#     is_manual_connection           = var.is_manual_connection
#     subresource_names              = try([var.subresource_name], null)
#     request_message                = try(var.request_message, null)
#   }

#   private_dns_zone_group {
#     name                 = var.private_dns_zone_group_name
#     private_dns_zone_ids = var.private_dns_zone_group_ids
#   }

#   lifecycle {
#     ignore_changes = [
#       tags
#     ]
#   }
# }

locals {
  # private_dns_zone_id    = length(var.private_endpoint) > 0 ? try(azurerm_private_dns_zone.dns_zone[0].id, data.azurerm_private_dns_zone.dns_zone[0].id) : null
  # private_dns_zone_name  = length(var.private_endpoint) > 0 ? try(azurerm_private_dns_zone.dns_zone[0].name, data.azurerm_private_dns_zone.dns_zone[0].name) : null
  # private_endpoint_links = length(var.private_endpoint) > 0 && var.private_dns_zone == null ? var.private_endpoint : {}
  module_tag = { "module" = basename(abspath(path.module)) }
  tags       = merge(var.tags, local.module_tag)
}

# resource "azurerm_private_endpoint" "this" {
#   for_each = var.private_endpoint

#   location            = each.value.location != null ? each.value.location : data.azurerm_resource_group.pe_vnet_rg[each.key].location
#   name                = each.value.name
#   resource_group_name = data.azurerm_resource_group.pe_vnet_rg[each.key].name
#   subnet_id           = data.azurerm_subnet.pe_subnet[each.key].id
#   tags                = local.tags

#   private_service_connection {
#     is_manual_connection           = each.value.is_manual_connection
#     name                           = each.value.private_service_connection_name
#     private_connection_resource_id = each.value.target_resource_id
#     subresource_names              = each.value.pe_subresource
#   }
#   dynamic "private_dns_zone_group" {
#     for_each = each.value.private_dns_entry_enabled ? ["private_dns_zone_group"] : []

#     content {
#       name                 = data.azurerm_private_dns_zone.dns_zone.name
#       private_dns_zone_ids = [data.azurerm_private_dns_zone.dns_zone.id]
#     }
#   }
# }



# # resource "azurerm_private_dns_zone" "dns_zone" {
# #   count = length(var.private_endpoint) > 0 && var.private_dns_zone == null ? 1 : 0

# #   name                = var.private_dns_zone.name
# #   resource_group_name = data.azurerm_resource_group.this.name
# #   tags                = local.tags
# # }

# resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
#   for_each = var.private_endpoint

#   name                  = each.value.dns_zone_virtual_network_link_name
#   private_dns_zone_name = each.value.private_dns_zone.name
#   resource_group_name   = data.azurerm_resource_group.pe_vnet_rg[each.key].name
#   virtual_network_id    = data.azurerm_virtual_network.vnet[each.key].id
#   registration_enabled  = each.value.dns_record == "" 
#   tags                  = local.tags
# }

# resource "azurerm_private_dns_a_record" "sa_dns_a_record" {
#   for_each = { for key, dns in var.private_endpoint : key => dns if dns.dns_record != "" }

#   name                = each.value.dns_record
#   zone_name           = data.azurerm_private_dns_zone.dns_zone[each.key].name
#   resource_group_name = data.azurerm_resource_group.pe_vnet_rg[each.key].name
#   records             = [azurerm_private_endpoint.this[each.key].private_service_connection[0].private_ip_address]
#   ttl                 = 300
#   depends_on          = [azurerm_private_endpoint.this]
# }










#------------------------------------------
# resource "azurerm_private_endpoint" "this" {
#   location            = var.location != null ? var.location : data.azurerm_resource_group.pe_vnet_rg[var.name].location
#   name                = var.name
#   resource_group_name = data.azurerm_resource_group.net_rg.name
#   subnet_id           = data.azurerm_subnet.pe_subnet.id
#   tags                = local.tags

#   private_service_connection {
#     is_manual_connection           = var.is_manual_connection
#     name                           = var.private_service_connection_name
#     private_connection_resource_id = var.target_resource_id
#     subresource_names              = var.subresource
#   }

#   dynamic "private_dns_zone_group" {
#     for_each = var.private_dns_entry_enabled ? ["private_dns_zone_group"] : []

#     content {
#       name                 = data.azurerm_private_dns_zone.dns_zone.name
#       private_dns_zone_ids = [data.azurerm_private_dns_zone.dns_zone.id]
#     }
#   }
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
#   name                  = var.dns_zone_virtual_network_link_name
#   private_dns_zone_name = data.azurerm_private_dns_zone.dns_zone.name
#   resource_group_name   = data.azurerm_resource_group.net_rg.name
#   virtual_network_id    = data.azurerm_virtual_network.vnet.id
#   registration_enabled  = var.dns_record == "" 
#   tags                  = local.tags
# }

# resource "azurerm_private_dns_a_record" "sa_dns_a_record" {
#   name                = var.dns_record
#   zone_name           = data.azurerm_private_dns_zone.dns_zone.name
#   resource_group_name = data.azurerm_resource_group.net_rg.name
#   records             = [azurerm_private_endpoint.this.private_service_connection[0].private_ip_address]
#   ttl                 = 300
#   depends_on          = [azurerm_private_endpoint.this]
# }


resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoint
  location            = each.value.location != null ? each.value.location : data.azurerm_resource_group.pe_vnet_rg[each.key].location
  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.pe_vnet_rg[each.key].name
  subnet_id           = data.azurerm_subnet.pe_subnet[each.key].id
  tags                = var.tags

  private_service_connection {
    is_manual_connection           = each.value.is_manual_connection
    name                           = each.value.private_service_connection_name
    private_connection_resource_id = each.value.target_resource_id
    subresource_names              = var.subresource
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_entry_enabled ? ["private_dns_zone_group"] : []

    content {
      name                 =  data.azurerm_private_dns_zone.dns_zone[each.key].name
      private_dns_zone_ids = [data.azurerm_private_dns_zone.dns_zone[each.key].id]
    }
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
  for_each = var.private_endpoint
  name                  = each.value.dns_zone_virtual_network_link_name
  private_dns_zone_name = data.azurerm_private_dns_zone.dns_zone[each.key].name
  resource_group_name   = data.azurerm_virtual_network.vnet[each.key].resource_group_name
  virtual_network_id    = data.azurerm_virtual_network.vnet[each.key].id
  registration_enabled  = var.dns_record == ""
  tags                  = var.tags
}

resource "azurerm_private_dns_a_record" "sa_dns_a_record" {
  for_each = var.private_endpoint
  name                = each.value.dns_zone_virtual_network_link_name
  zone_name           = data.azurerm_private_dns_zone.dns_zone[each.key].name
  resource_group_name = data.azurerm_resource_group.net_rg[each.key].name
  records             = [azurerm_private_endpoint.this.private_service_connection[0].private_ip_address]
  ttl                 = 300
  depends_on          = [azurerm_private_endpoint.this]
}
