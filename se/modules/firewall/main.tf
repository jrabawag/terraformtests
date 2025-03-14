resource "azurerm_firewall_policy" "policy" {
  name                = "${var.name}-policy"
  resource_group_name = var.resource_group_name
  location            = var.location

  dns {
    proxy_enabled = var.dns_proxy_enabled
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "network_policy" {
  for_each           = tomap({ for col in var.network_rule_collections : col.name => col })
  name               = each.key
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = each.value.priority


  dynamic "network_rule_collection" {
    for_each = [each.value]
    content {
      name     = network_rule_collection.value.name
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name                  = rule.value.name
          source_addresses      = rule.value.source_addresses
          destination_ports     = rule.value.destination_ports
          destination_fqdns     = rule.value.destination_fqdns
          destination_addresses = rule.value.destination_addresses
          protocols             = rule.value.protocols
        }
      }
    }
  }
  timeouts {
    create = "60m"
    update = "60m"
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "application_policy" {
  for_each           = tomap({ for col in var.application_rule_collections : col.name => col })
  name               = each.key
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = each.value.priority

  dynamic "application_rule_collection" {
    for_each = [each.value]
    content {
      name     = application_rule_collection.value.name
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name                  = rule.value.name
          source_addresses      = rule.value.source_addresses
          destination_fqdn_tags = rule.value.destination_fqdn_tags
          destination_fqdns     = rule.value.destination_fqdns

          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              port = protocols.value.port
              type = protocols.value.type
            }
          }
        }
      }
    }
  }
  timeouts {
    create = "60m"
    update = "60m"
  }
}

resource "azurerm_firewall" "firewall" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  zones               = var.zones
  threat_intel_mode   = var.threat_intel_mode
  sku_tier            = var.sku_tier
  sku_name            = var.sku_name
  firewall_policy_id  = azurerm_firewall_policy.policy.id

  ip_configuration {
    name                 = "fw_ip_config"
    subnet_id            = var.subnet_id
    public_ip_address_id = var.public_ip_address_id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_firewall.firewall.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  metric {
    category = "AllMetrics"
  }

  lifecycle {
    ignore_changes = all
  }
}
