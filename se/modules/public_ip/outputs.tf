output "id" {
  description = "The ID of the public IP."
  value = azurerm_public_ip.pip.id
}

output "prefix_id" {
  value       = azurerm_public_ip_prefix.prefix.id
  description = "The ID of the public IP prefix."
}

output "public_ip_address" {
  value       = azurerm_public_ip.pip.ip_address
  description = "The allocated public IP address."
}

