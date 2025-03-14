# FJRA
module "openai" {
  source                             = "../../modulesSEV2/open_ai"
  for_each                           = { for key, openai in var.openai : key => openai }
  account_name                       = "openai-${var.shortproject}-${each.value.region}-${each.value.name}-${lower(var.environment)}"
  custom_subdomain_name              = var.shortproject
  resource_group_name                = module.resource_groups[local.assign_region[each.key].region].resource_groups[each.value.resource_group].name
  location                           = local.locations_map[each.value.region]
  public_network_access_enabled      = !each.value.is_private
  outbound_network_access_restricted = each.value.outbound_network_access_restricted
  tags                               = local.default_tags

  deployment = {
    for model in each.value.models_deployment : model => var.deployments[model]
  }
  
  # customer_managed_key = {
  #   key_vault_key_id   = 
  #   identity_client_id =
  # }

  network_acls = !each.value.is_private ? {
    for key, value in var.openai : key => {
      default_action = "Deny"
      ip_rules       = var.acl_allow_ip
      virtual_network_rules = { for key, subnet in module.network[local.assign_region[each.key].region].subnet_ids : subnet => {
        subnet_id                            = subnet
        ignore_missing_vnet_service_endpoint = false
        }
      }
    } if !value.is_private } : {}

  diagnostic_setting = {
    default = {
      name                       = "Diagnostic_setting"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics[local.assign_region[each.key].region].id
      audit_log_retention_policy = {
        enabled = true
      }
      request_response_log_retention_policy = {
        enabled = true
      }
      trace_log_retention_policy = {
        enabled = true
      }
      metric_retention_policy = {
        enabled = true
      }
    }
  }

  depends_on = [
    module.resource_groups,
    module.network
  ]
}

# module "private_endpoint" {
#   source = "../../modulesSEV2/private_endpoint"
#   for_each = { for key, openai in var.openai : key => {

#   name                            = "${var.shortproject}-${openai.name}-private-endpoint"
#   location                        = local.assign_region[key].region
#   dns_record                      = "${lower(var.project)}-${openai.name}"
#   subnet_name                     = module.network[lookup(var.network_data, key, null) != null ? key : var.default_region].subnet_names["pe"]
#   vnet_name                       = module.network[lookup(var.network_data, key, null) != null ? key : var.default_region].vnet_names
#   vnet_rg_name                    = module.network[lookup(var.network_data, key, null) != null ? key : var.default_region].vnet_rg
#   target_resource_id              = module.openai[key].openai_id
#   pe_subresource                  = ["account"]
#   private_dns_zone                = azurerm_private_dns_zone.private_dns_zones[lookup(var.network_data, key, null) != null ? key : var.default_region].name
#   dns_zone_virtual_network_link   = "${key}_dns_zone_link"
#   private_dns_entry_enabled       = true
#   private_service_connection_name = "pe-${openai.name}-connection"
#   is_manual_connection            = false
#   } if openai.is_private == false}
# }
module "private_endpoint" {
  source = "../../modulesSEV2/private_endpoint"
  for_each = { for key, openai in var.openai : key => openai if openai.is_private == true && length(openai.is_private) > 0}

  name                            = "${var.shortproject}-${each.value.name}-private-endpoint"
  location                        = local.assign_region[each.key].region
  dns_record                      = "${lower(var.project)}-${each.value.name}"
  target_resource_id              = module.openai[each.key].openai_id
  subresource                     = ["account"]
  dns_zone_virtual_network_link_name   = "${each.key}_dns_zone_link"
  private_service_connection_name = "pe-${each.value.name}-connection"
  # Existing Resource
  data = {
  subnet_name                     = module.network[local.assign_region[each.key].region].subnet_names["pe"]
  vnet_name                       = module.network[local.assign_region[each.key].region].vnet_names
  netowrk_rg                    = module.network[local.assign_region[each.key].region].vnet_rg
  priv_dns_name                = azurerm_private_dns_zone.private_dns_zones[local.assign_region[each.key].region].name
  }
}