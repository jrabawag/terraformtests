output "firewall_policy_id" {
  description = "The ID of the Azure Firewall Policy"
  value       = azurerm_firewall_policy.policy.id
}

output "firewall_id" {
  description = "The ID of the Azure Firewall"
  value       = azurerm_firewall.firewall.id
}

output "firewall_private_ip" {
  description = "The private IP address of the Azure Firewall"
  value       = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}