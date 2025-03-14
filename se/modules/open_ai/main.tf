terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

  required_version = ">= 0.14.9"
}

data "azurerm_key_vault" "central_key_vault" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_resource_group_name
}

resource "azurerm_cognitive_account" "openai" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = var.tags
  custom_subdomain_name         = var.name
  kind                          = "OpenAI"
  public_network_access_enabled = var.public_network_access_enabled
  sku_name                      = "S0"
  local_auth_enabled            = false
  identity {
    type = "SystemAssigned"
  }

  network_acls {
    default_action = "Deny"

    dynamic "virtual_network_rules" {
      for_each = var.subnet_ids
      content {
        subnet_id = virtual_network_rules.value
      }
    }
    // virtual_network_rules = var.subnet_ids
    ip_rules = var.netacl_ip_rules
  }
}

# resource "azurerm_key_vault_secret" "openai_endpoint" {
#   name         = "${azurerm_cognitive_account.openai.name}-openai-endpoint"
#   value        = azurerm_cognitive_account.openai.endpoint
#   key_vault_id = data.azurerm_key_vault.central_key_vault.id
#   depends_on = [ azurerm_cognitive_account.openai ]
# }

# resource "azurerm_key_vault_secret" "openai_key1" {
#   name         = "${azurerm_cognitive_account.openai.name}-openai-primaryacceskey"
#   value        = azurerm_cognitive_account.openai.primary_access_key
#   key_vault_id = data.azurerm_key_vault.central_key_vault.id
#   depends_on = [ azurerm_cognitive_account.openai ]
# }


resource "azurerm_monitor_diagnostic_setting" "setting" {
  # for_each = var.diagnostic_setting
  count                      = var.log_analytics_workspace_enable == true ? 1 : 0
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_cognitive_account.openai.id
  log_analytics_workspace_id = var.log_analytics_workspace_id


  enabled_log {
    category = "Audit"
  }
  enabled_log {
    category = "RequestResponse"
  }
  enabled_log {
    category = "Trace"
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

#DATA VNET
data "azurerm_virtual_network" "vnet" {
  name                = var.private_endpoint.vnet_name
  resource_group_name = var.private_endpoint.vnet_rg
}

#Private Endpoint
resource "azurerm_private_endpoint" "opai_private_endpoint" {
  count               = var.private_endpoint.enable ? 1 : 0
  name                = "pe-${var.name}-private-endpoint"
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  location            = data.azurerm_virtual_network.vnet.location
  subnet_id           = var.private_endpoint.subnet_id

  private_service_connection {
    name                           = "${var.name}-connection"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }
  depends_on = [azurerm_cognitive_account.openai]
}

# Private Endpoint Connection Data
data "azurerm_private_endpoint_connection" "private_ip1" {
  count               = var.private_endpoint.enable ? 1 : 0
  name                = azurerm_private_endpoint.opai_private_endpoint[0].name
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  depends_on          = [azurerm_private_endpoint.opai_private_endpoint]
}

# Conditional Private DNS Zone Link
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
  count                 = var.private_endpoint.enable ? 1 : 0
  name                  = "${azurerm_cognitive_account.openai.name}-dns-link"
  resource_group_name   = data.azurerm_virtual_network.vnet.resource_group_name
  private_dns_zone_name = var.private_endpoint.private_dns_zone_name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
  registration_enabled  = false
  depends_on            = [azurerm_private_endpoint.opai_private_endpoint]
}

# Conditional Private DNS A Record
resource "azurerm_private_dns_a_record" "opai_dns_a_record" {
  count               = var.private_endpoint.enable ? 1 : 0
  name                = azurerm_cognitive_account.openai.name
  zone_name           = var.private_endpoint.private_dns_zone_name
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  records             = [data.azurerm_private_endpoint_connection.private_ip1[0].private_service_connection[0].private_ip_address]
  ttl                 = 300
  depends_on          = [azurerm_private_endpoint.opai_private_endpoint]
}