terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

  required_version = ">= 0.14.9"
}

locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = merge(var.tags, local.module_tag)
}

resource "azurerm_key_vault" "key_vault" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = var.tenant_id
  sku_name                        = var.sku_name
  tags                            = var.tags
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
  soft_delete_retention_days      = var.soft_delete_retention_days
  public_network_access_enabled   = var.public_network_access_enabled

  timeouts {
    delete = "60m"
  }
  network_acls {
    default_action             = (length(var.ip_rules) + length(var.virtual_network_subnet_ids)) > 0 ? "Deny" : var.default_action
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
    bypass                     = var.bypass
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  count                      = var.log_analytics_workspace_enable == true ? 1 : 0
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_key_vault.key_vault.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
  }
}

#DATA VNET
data "azurerm_virtual_network" "vnet" {
  count               = var.private_endpoint.enable ? 1 : 0
  name                = var.private_endpoint.vnet_name
  resource_group_name = var.private_endpoint.vnet_rg
}

# Private Endpoint
resource "azurerm_private_endpoint" "kv_private_endpoint" {
  count               = var.private_endpoint.enable ? 1 : 0
  name                = "pe-${var.name}"
  resource_group_name = data.azurerm_virtual_network.vnet[count.index].resource_group_name
  location            = data.azurerm_virtual_network.vnet[count.index].location
  subnet_id           = var.private_endpoint.subnet_id

  private_service_connection {
    name                           = "${var.name}-connection"
    private_connection_resource_id = azurerm_key_vault.key_vault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
  depends_on = [azurerm_key_vault.key_vault]
}

# Private Endpoint Connection Data
data "azurerm_private_endpoint_connection" "private_ip1" {
  count               = var.private_endpoint.enable ? 1 : 0
  name                = azurerm_private_endpoint.kv_private_endpoint[0].name
  resource_group_name = data.azurerm_virtual_network.vnet[count.index].resource_group_name
  depends_on          = [azurerm_key_vault.key_vault]
}

# Conditional Private DNS Zone Link
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
  count                 = var.private_endpoint.enable ? 1 : 0
  name                  = "${azurerm_key_vault.key_vault.name}-dns-link"
  resource_group_name   = data.azurerm_virtual_network.vnet[count.index].resource_group_name
  private_dns_zone_name = var.private_endpoint.private_dns_zone_name
  virtual_network_id    = data.azurerm_virtual_network.vnet[count.index].id
  registration_enabled  = false
  depends_on            = [azurerm_private_endpoint.kv_private_endpoint]
}

# Conditional Private DNS A Record
resource "azurerm_private_dns_a_record" "kv_dns_a_record" {
  count               = var.private_endpoint.enable ? 1 : 0
  name                = azurerm_key_vault.key_vault.name
  zone_name           = var.private_endpoint.private_dns_zone_name
  resource_group_name = data.azurerm_virtual_network.vnet[count.index].resource_group_name
  records             = [data.azurerm_private_endpoint_connection.private_ip1[0].private_service_connection[0].private_ip_address]
  ttl                 = 300
  depends_on          = [azurerm_private_endpoint.kv_private_endpoint]
}
