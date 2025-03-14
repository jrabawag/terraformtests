resource "azurerm_firewall_policy_rule_collection_group" "network_policy" {
  name               = var.name
  firewall_policy_id = var.firewall_policy_id
  priority           = var.priority

  dynamic "network_rule_collection" {
    for_each = var.network_rule_collections
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
          protocols             = rule.value.protocols
          destination_fqdns     = length(rule.value.destination_fqdns) > 0 ? rule.value.destination_fqdns : null
          destination_addresses = length(rule.value.destination_addresses) > 0 ? rule.value.destination_addresses : null
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      application_rule_collection,
      #network_rule_collection,
      nat_rule_collection
    ]
  }
}
