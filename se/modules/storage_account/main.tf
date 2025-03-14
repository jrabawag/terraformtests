# # terraform {
# #   required_providers {
# #     azurerm = {
# #       source = "hashicorp/azurerm"
# #     }
# #   }

# #   required_version = ">= 0.14.9"
# # }


# locals {
#   module_tag = {
#     "module" = basename(abspath(path.module))
#   }
#   tags = merge(var.tags, local.module_tag)
# }

# # Storage Account
# resource "azurerm_storage_account" "storage_account" {
#   name                = var.name
#   resource_group_name = var.resource_group_name

#   location                          = var.location
#   account_kind                      = var.account_kind
#   account_tier                      = var.account_tier
#   account_replication_type          = var.replication_type
#   is_hns_enabled                    = var.is_hns_enabled
#   https_traffic_only_enabled        = var.enable_https_traffic_only
#   allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
#   infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
#   shared_access_key_enabled         = var.shared_access_key_enabled
#   tags                              = local.tags

#   network_rules {
#     default_action             = (length(var.ip_rules) + length(var.virtual_network_subnet_ids)) > 0 ? "Deny" : var.default_action
#     ip_rules                   = var.ip_rules
#     virtual_network_subnet_ids = var.virtual_network_subnet_ids
#     bypass                     = [var.bypass]
#   }


#   identity {
#     type = "SystemAssigned"
#   }

#   dynamic "sas_policy" {
#     for_each = var.shared_access_key_enabled ? [1] : []

#     content {
#       expiration_action = "Log"
#       expiration_period = "0.01:00:00"
#     }
#   }

#   lifecycle {
#     ignore_changes = [
#       tags,
#       shared_access_key_enabled
#     ]
#   }
# }

# # Storage Account Diagnostics Settings
# #
# # Data source to fetch all available log and metrics categories, enabling all.
# data "azurerm_monitor_diagnostic_categories" "storage" {
#   resource_id = azurerm_storage_account.storage_account.id
# }

# resource "azurerm_monitor_diagnostic_setting" "settings" {
#   name                       = "coreDiagnosticsSettings"
#   count                      = var.log_analytics_workspace_enable == true ? 1 : 0
#   target_resource_id         = azurerm_storage_account.storage_account.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   # dynamic "log" {
#   #   iterator = entry
#   #   for_each = data.azurerm_monitor_diagnostic_categories.storage.logs
#   #   content {
#   #     category = entry.value
#   #     enabled  = true

#   #     retention_policy {
#   #       enabled = true
#   #       days    = var.log_analytics_retention_days
#   #     }
#   #   }
#   # }

#   dynamic "metric" {
#     iterator = entry
#     for_each = data.azurerm_monitor_diagnostic_categories.storage.metrics

#     content {
#       category = entry.value
#       enabled  = true
#     }
#   }
# }

# # Below log settings for blob service of a storage account
# data "azurerm_monitor_diagnostic_categories" "storage_blob" {
#   resource_id = "${azurerm_storage_account.storage_account.id}/blobServices/default/"
# }

# resource "azurerm_monitor_diagnostic_setting" "storage_blob" {
#   name                       = "blobDiagnosticsSettings"
#   count                      = var.log_analytics_workspace_enable == true ? 1 : 0
#   target_resource_id         = "${azurerm_storage_account.storage_account.id}/blobServices/default/"
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "enabled_log" {
#     iterator = entry
#     for_each = data.azurerm_monitor_diagnostic_categories.storage_blob.log_category_types

#     content {
#       category = entry.value
#     }
#   }

#   dynamic "metric" {
#     iterator = entry
#     for_each = data.azurerm_monitor_diagnostic_categories.storage_blob.metrics

#     content {
#       category = entry.value
#       enabled  = true
#     }
#   }
# }

# # Below log settings for queue service of a storage account
# data "azurerm_monitor_diagnostic_categories" "storage_queue" {
#   resource_id = "${azurerm_storage_account.storage_account.id}/queueServices/default/"
# }

# resource "azurerm_monitor_diagnostic_setting" "storage_queue" {
#   name                       = "queueDiagnosticsSettings"
#   count                      = var.log_analytics_workspace_enable == true ? 1 : 0
#   target_resource_id         = "${azurerm_storage_account.storage_account.id}/queueServices/default/"
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "enabled_log" {
#     iterator = entry
#     for_each = data.azurerm_monitor_diagnostic_categories.storage_queue.log_category_types

#     content {
#       category = entry.value
#     }
#   }

#   dynamic "metric" {
#     iterator = entry
#     for_each = data.azurerm_monitor_diagnostic_categories.storage_queue.metrics

#     content {
#       category = entry.value
#       enabled  = true
#     }
#   }
# }

# # Below log settings for table service of a storage account
# data "azurerm_monitor_diagnostic_categories" "storage_table" {
#   resource_id = "${azurerm_storage_account.storage_account.id}/tableServices/default/"
# }

# resource "azurerm_monitor_diagnostic_setting" "storage_table" {
#   name                       = "tableDiagnosticsSettings"
#   count                      = var.log_analytics_workspace_enable == true ? 1 : 0
#   target_resource_id         = "${azurerm_storage_account.storage_account.id}/tableServices/default/"
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "enabled_log" {
#     iterator = entry
#     for_each = data.azurerm_monitor_diagnostic_categories.storage_table.log_category_types

#     content {
#       category = entry.value
#     }
#   }

#   dynamic "metric" {
#     iterator = entry
#     for_each = data.azurerm_monitor_diagnostic_categories.storage_table.metrics

#     content {
#       category = entry.value
#       enabled  = true
#     }
#   }
# }

# # Below log settings for file service of a storage account
# data "azurerm_monitor_diagnostic_categories" "storage_file" {
#   resource_id = "${azurerm_storage_account.storage_account.id}/fileServices/default/"
# }

# resource "azurerm_monitor_diagnostic_setting" "storage_file" {
#   name                       = "fileDiagnosticsSettings"
#   count                      = var.log_analytics_workspace_enable == true ? 1 : 0
#   target_resource_id         = "${azurerm_storage_account.storage_account.id}/fileServices/default/"
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "enabled_log" {
#     iterator = entry
#     for_each = data.azurerm_monitor_diagnostic_categories.storage_file.log_category_types

#     content {
#       category = entry.value
#     }
#   }

#   dynamic "metric" {
#     iterator = entry
#     for_each = data.azurerm_monitor_diagnostic_categories.storage_file.metrics

#     content {
#       category = entry.value
#       enabled  = true
#     }
#   }
# }
locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = merge(var.tags, local.module_tag)
}

# Storage Account
resource "azurerm_storage_account" "storage_account" {
  name                              = var.name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_kind                      = var.account_kind
  account_tier                      = var.account_tier
  account_replication_type          = var.replication_type
  is_hns_enabled                    = var.is_hns_enabled
  https_traffic_only_enabled        = var.enable_https_traffic_only
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  shared_access_key_enabled         = var.shared_access_key_enabled
  tags                              = local.tags

  network_rules {
    default_action             = length(var.ip_rules) + length(var.virtual_network_subnet_ids) > 0 ? "Deny" : var.default_action
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
    bypass                     = var.bypass
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "sas_policy" {
    for_each = var.shared_access_key_enabled ? [1] : []
    content {
      expiration_action = "Log"
      expiration_period = "0.01:00:00"
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
      shared_access_key_enabled,
      network_rules
    ]
  }
}

#Container
resource "azurerm_storage_container" "sa_container" {
  for_each              = var.containers
  name                  = each.key
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = each.value.container_access_type
}


# # Diagnostic Categories
# data "azurerm_monitor_diagnostic_categories" "storage" {
#   resource_id = azurerm_storage_account.storage_account.id
# }

# # Unified Diagnostic Settings
# resource "azurerm_monitor_diagnostic_setting" "settings" {
#   count                      = var.log_analytics_workspace_enable ? 1 : 0
#   name                       = "coreDiagnosticsSettings"
#   target_resource_id         = azurerm_storage_account.storage_account.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "log" {
#     for_each = data.azurerm_monitor_diagnostic_categories.storage.logs
#     content {
#       category = log.value
#       enabled  = true

#       retention_policy {
#         enabled = true
#         days    = var.log_analytics_retention_days
#       }
#     }
#   }

#   dynamic "metric" {
#     for_each = data.azurerm_monitor_diagnostic_categories.storage.metrics
#     content {
#       category = metric.value
#       enabled  = true
#     }
#   }
# }

# # Additional Services Diagnostics
# locals {
#   services = ["blob", "queue", "table", "file"]
# }

# resource "azurerm_monitor_diagnostic_setting" "storage_services" {
#   for_each = var.log_analytics_workspace_enable ? toset(local.services) : {}

#   name                       = "${each.key}DiagnosticsSettings"
#   target_resource_id         = "${azurerm_storage_account.storage_account.id}/${each.key}Services/default/"
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "log" {
#     for_each = data.azurerm_monitor_diagnostic_categories["storage_${each.key}"].log_category_types
#     content {
#       category = log.value
#       enabled  = true
#     }
#   }

#   dynamic "metric" {
#     for_each = data.azurerm_monitor_diagnostic_categories["storage_${each.key}"].metrics
#     content {
#       category = metric.value
#       enabled  = true
#     }
#   }
# }

# # Diagnostic Categories for Each Service
# data "azurerm_monitor_diagnostic_categories" "storage_blob" {
#   resource_id = "${azurerm_storage_account.storage_account.id}/blobServices/default/"
# }

# data "azurerm_monitor_diagnostic_categories" "storage_queue" {
#   resource_id = "${azurerm_storage_account.storage_account.id}/queueServices/default/"
# }

# data "azurerm_monitor_diagnostic_categories" "storage_table" {
#   resource_id = "${azurerm_storage_account.storage_account.id}/tableServices/default/"
# }

# data "azurerm_monitor_diagnostic_categories" "storage_file" {
#   resource_id = "${azurerm_storage_account.storage_account.id}/fileServices/default/"
# }




#DATA VNET
data "azurerm_virtual_network" "vnet" {
  name                = var.private_endpoint.vnet_name
  resource_group_name = var.private_endpoint.vnet_rg
}

#Private Endpoint
resource "azurerm_private_endpoint" "storage_private_endpoint" {
  count               = var.private_endpoint.enable ? 1 : 0
  name                = "pe-${var.name}-private-endpoint"
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  location            = data.azurerm_virtual_network.vnet.location
  subnet_id           = var.private_endpoint.subnet_id
  depends_on          = [azurerm_storage_account.storage_account]

  private_service_connection {
    name                           = "${var.name}-connection"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

}

data "azurerm_private_endpoint_connection" "private_ip1" {
  count               = var.private_endpoint.enable ? 1 : 0
  name                = azurerm_private_endpoint.storage_private_endpoint[0].name
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  depends_on          = [azurerm_private_endpoint.storage_private_endpoint]
}

# Conditional Private DNS Zone Link
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
  count                 = var.private_endpoint.enable ? 1 : 0
  name                  = "${azurerm_storage_account.storage_account.name}-dns-link"
  resource_group_name   = data.azurerm_virtual_network.vnet.resource_group_name
  private_dns_zone_name = var.private_endpoint.private_dns_zone_name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
  registration_enabled  = false
  depends_on            = [azurerm_private_endpoint.storage_private_endpoint]
}

# Conditional Private DNS A Record
resource "azurerm_private_dns_a_record" "sa_dns_a_record" {
  count               = var.private_endpoint.enable ? 1 : 0
  name                = azurerm_storage_account.storage_account.name
  zone_name           = var.private_endpoint.private_dns_zone_name
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  records             = [data.azurerm_private_endpoint_connection.private_ip1[0].private_service_connection[0].private_ip_address]
  ttl                 = 300
  depends_on          = [azurerm_private_endpoint.storage_private_endpoint]
}