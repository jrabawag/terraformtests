#FJRA
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  required_version = ">= 0.14.9"
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "random_integer" "this" {
  max = 99999
  min = 10000
}

locals {
  location              = coalesce(var.location, data.azurerm_resource_group.this.location)
  account_name          = coalesce(var.account_name, "openai-${random_integer.this.result}")
  custom_subdomain_name = coalesce(var.custom_subdomain_name, "openai-${random_integer.this.result}")
  module_tag = { "module" = basename(abspath(path.module)) }
  tags = merge(var.tags, local.module_tag)
}

# COGNITIVE ACCOUNT OPENAI
resource "azurerm_cognitive_account" "this" {
  kind                               = "OpenAI"
  location                           = local.location
  name                               = local.account_name
  resource_group_name                = data.azurerm_resource_group.this.name
  sku_name                           = var.sku_name
  custom_subdomain_name              = local.custom_subdomain_name
  dynamic_throttling_enabled         = var.dynamic_throttling_enabled
  fqdns                              = var.fqdns
  local_auth_enabled                 = var.local_auth_enabled
  outbound_network_access_restricted = var.outbound_network_access_restricted
  public_network_access_enabled      = var.public_network_access_enabled
  tags                               = local.tags

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? [var.customer_managed_key] : []

    content {
      key_vault_key_id   = customer_managed_key.value.key_vault_key_id
      identity_client_id = customer_managed_key.value.identity_client_id
    }
  }
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
  dynamic "network_acls" {
    for_each = var.network_acls != null ? var.network_acls : {}
    content {
      default_action = network_acls.value != null ? network_acls.value.default_action : "Allow"
      ip_rules       = network_acls.value.ip_rules
      dynamic "virtual_network_rules" {
        for_each = network_acls.value.virtual_network_rules != null ? tomap(network_acls.value.virtual_network_rules) : tomap({})
        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = virtual_network_rules.value.ignore_missing_vnet_service_endpoint
        }
      }
    }
  }
}


#MODEL DEPLOYMENTS
resource "azurerm_cognitive_deployment" "this" {
  for_each = var.deployment

  cognitive_account_id       = azurerm_cognitive_account.this.id
  name                       = each.value.deployment_id
  rai_policy_name            = each.value.rai_policy_name
  dynamic_throttling_enabled = each.value.dynamic_throttling_enabled
  version_upgrade_option     = each.value.version_upgrade_option
  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }
  sku {
    name     = each.value.sku_name
    tier     = each.value.sku_tier
    size     = each.value.sku_size
    family   = each.value.sku_family
    capacity = each.value.sku_capacity
  }
}


# DIAGNOSTICS
resource "azurerm_monitor_diagnostic_setting" "setting" {
  for_each = var.diagnostic_setting

  name                           = each.value.name
  target_resource_id             = azurerm_cognitive_account.this.id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name
  log_analytics_destination_type = each.value.log_analytics_destination_type
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  partner_solution_id            = each.value.partner_solution_id
  storage_account_id             = each.value.storage_account_id

  dynamic "enabled_log" {
    for_each = try(each.value.audit_log_retention_policy.enabled, null) == null ? [] : [1]
    content {
      category = "Audit"
    }
  }
  dynamic "enabled_log" {
    for_each = try(each.value.request_response_log_retention_policy.enabled, null) == null ? [] : [1]
    content {
      category = "RequestResponse"
    }
  }
  dynamic "enabled_log" {
    for_each = try(each.value.trace_log_retention_policy.enabled, null) == null ? [] : [1]
    content {
      category = "Trace"
    }
  }
  dynamic "metric" {
    for_each = try(each.value.metric_retention_policy.enabled, null) == null ? [] : [1]
    content {
      category = "AllMetrics"
    }
  }
}



# # locals {
# #   account_name          = coalesce(var.account_name, "azure-openai-${random_integer.this.result}")
# #   custom_subdomain_name = coalesce(var.custom_subdomain_name, "azure-openai-${random_integer.this.result}")
# #   tags = merge(var.default_tags_enabled ? {
# #     Application_Name = var.application_name
# #     Environment      = var.environment
# #   } : {}, var.tags)
# # }

# data "azurerm_key_vault" "central_key_vault" {
#   name                = var.keyvault_name
#   resource_group_name = var.keyvault_resource_group_name
# }

# resource "azurerm_cognitive_account" "openai" {
#   name                          = var.name
#   location                      = var.location
#   resource_group_name           = var.resource_group_name
#   tags                          = var.tags
#   custom_subdomain_name         = var.name
#   kind                          = "OpenAI"
#   public_network_access_enabled = var.public_network_access_enabled
#   sku_name                      = "S0"
#   local_auth_enabled            = false
#   identity {
#     type = "SystemAssigned"
#   }

# dynamic "network_acls" {
#     for_each = var.private_endpoint.enable == false ? [1] : []
#     content {
#       default_action = (length(var.netacl_ip_rules) + length(var.subnet_ids)) > 0 ? "Deny" : var.default_action
#       ip_rules = var.netacl_ip_rules
#       dynamic "virtual_network_rules" {
#         for_each = var.subnet_ids
#         content {
#         subnet_id = each.value   
#         }
#       }
#     } 
#   }
# }




# # resource "azurerm_key_vault_secret" "openai_endpoint" {
# #   name         = "${azurerm_cognitive_account.openai.name}-openai-endpoint"
# #   value        = azurerm_cognitive_account.openai.endpoint
# #   key_vault_id = data.azurerm_key_vault.central_key_vault.id
# #   depends_on = [ azurerm_cognitive_account.openai ]
# # }

# # resource "azurerm_key_vault_secret" "openai_key1" {
# #   name         = "${azurerm_cognitive_account.openai.name}-openai-primaryacceskey"
# #   value        = azurerm_cognitive_account.openai.primary_access_key
# #   key_vault_id = data.azurerm_key_vault.central_key_vault.id
# #   depends_on = [ azurerm_cognitive_account.openai ]
# # }


# resource "azurerm_monitor_diagnostic_setting" "setting" {
#   # for_each = var.diagnostic_setting
#   count                      = var.log_analytics_workspace_enable == true ? 1 : 0
#   name                       = "DiagnosticsSettings"
#   target_resource_id         = azurerm_cognitive_account.openai.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id


#   enabled_log {
#     category = "Audit"
#   }
#   enabled_log {
#     category = "RequestResponse"
#   }
#   enabled_log {
#     category = "Trace"
#   }
#   metric {
#     category = "AllMetrics"
#     enabled  = true
#   }
# }

# #DATA VNET
# data "azurerm_virtual_network" "vnet" {
#   name                = var.private_endpoint.vnet_name
#   resource_group_name = var.private_endpoint.vnet_rg
# }

# #Private Endpoint
# resource "azurerm_private_endpoint" "opai_private_endpoint" {
#   count               = var.private_endpoint.enable ? 1 : 0
#   name                = "pe-${var.name}-private-endpoint"
#   resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
#   location            = data.azurerm_virtual_network.vnet.location
#   subnet_id           = var.private_endpoint.subnet_id

#   private_service_connection {
#     name                           = "${var.name}-connection"
#     private_connection_resource_id = azurerm_cognitive_account.openai.id
#     is_manual_connection           = false
#     subresource_names              = ["account"]
#   }
#   depends_on = [azurerm_cognitive_account.openai]
# }

# # Private Endpoint Connection Data
# data "azurerm_private_endpoint_connection" "private_ip1" {
#   count               = var.private_endpoint.enable ? 1 : 0
#   name                = azurerm_private_endpoint.opai_private_endpoint[0].name
#   resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
#   depends_on          = [azurerm_private_endpoint.opai_private_endpoint]
# }

# # Conditional Private DNS Zone Link
# resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
#   count                 = var.private_endpoint.enable ? 1 : 0
#   name                  = "${azurerm_cognitive_account.openai.name}-dns-link"
#   resource_group_name   = data.azurerm_virtual_network.vnet.resource_group_name
#   private_dns_zone_name = var.private_endpoint.private_dns_zone_name
#   virtual_network_id    = data.azurerm_virtual_network.vnet.id
#   registration_enabled  = false
#   depends_on            = [azurerm_private_endpoint.opai_private_endpoint]
# }

# # Conditional Private DNS A Record
# resource "azurerm_private_dns_a_record" "opai_dns_a_record" {
#   count               = var.private_endpoint.enable ? 1 : 0
#   name                = azurerm_cognitive_account.openai.name
#   zone_name           = var.private_endpoint.private_dns_zone_name
#   resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
#   records             = [data.azurerm_private_endpoint_connection.private_ip1[0].private_service_connection[0].private_ip_address]
#   ttl                 = 300
#   depends_on          = [azurerm_private_endpoint.opai_private_endpoint]
# }