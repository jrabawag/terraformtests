#FJRA
output "EXISTING_NETWORK" {
  description = "Specifies the details of the existing SE network (not created by this root module)"
  value = {
    for key, vnet in module.network : key => {
      vnet              = vnet.vnet_names
      subnets           = [for subnet in vnet.subnet_names : subnet]
      private_dns_zones = lookup(azurerm_private_dns_zone.private_dns_zones, key, null) != null ? azurerm_private_dns_zone.private_dns_zones[key].name : "NO PRIVATE DNS ZONE on this region"
    }
  }
}
# if subnet.subnet_vnetids == vnet.vnet_ids
output "EXISTING_RESOURCES" {
  description = "Map of all existing resources used by SE (not created by this root module)"
  value = {
    for key in keys(var.resource_data) : key => merge(
      lookup(module.resource_groups, key, null) != null ? { resource_group_names = [for rg in values(module.resource_groups[key].resource_groups) : rg.name] } : {},
      lookup(azurerm_firewall.firewall, key, null) != null ? { firewalls = azurerm_firewall.firewall[key].name } : {},
      lookup(azurerm_key_vault.keyvault, key, null) != null ? { keyvaults = azurerm_key_vault.keyvault[key].name } : {},
      lookup(azurerm_log_analytics_workspace.log_analytics, key, null) != null ? { log_analytics = azurerm_log_analytics_workspace.log_analytics[key].name } : {}
    )
  }
}

output "CGNITIVE_ACCOUNT_OpenAI" {
  description = "A map of OpenAI resources including the models assigned to them."
  value = {
    for key, resource in module.openai :
    key => {
      openai_name                   = resource.name
      sub_domain                    = resource.openai_subdomain
      resource_group_name           = resource.resource_group_name
      endpoint                      = resource.openai_endpoint
      models_assigned               = [for model_key, model in resource.openai_deployments : model.name if model.cognitive_account_id == resource.openai_id]
      private_endpoint_enabled      = lookup(module.private_endpoint, key, null) == null ? false : true
      local_auth_enabled            = resource.local_auth_enabled
      public_network_access_enabled = resource.public_network_access_enabled
    }
  }
}

output "Private" {
  description = "A map of OpenAI resources including the models assigned to them."
  value = {
    for key, resource in module.private_endpoint :
    key => resource.private_endpoint_config
  }
}

#  [
#         for model_key, model in resource.openai_deployments :
#         {
#           deployment_id             = model.name
#           rai_policy_name           = lookup(model, "rai_policy_name", null)
#           dynamic_throttling_enabled = lookup(model, "dynamic_throttling_enabled", null)
#           version_upgrade_option    = lookup(model, "version_upgrade_option", null)
#           model_format              = lookup(model.model[0], "format", null)
#           model_name                = lookup(model.model[0], "name", null)
#           model_version             = lookup(model.model[0], "version", null)
#           sku_name                  = lookup(model.sku[0], "name", null)
#           sku_tier                  = lookup(model.sku[0], "tier", null)
#           sku_size                  = lookup(model.sku[0], "size", null)
#           sku_family                = lookup(model.sku[0], "family", null)
#           sku_capacity              = lookup(model.sku[0], "capacity", null)
#         } if model.cognitive_account_id == resource.openai_id
#       ]