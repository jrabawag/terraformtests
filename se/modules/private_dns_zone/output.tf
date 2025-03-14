# output "dns_zone_names" {
#   description = "The names of the created private DNS zones."
#   value       = [for zone in azurerm_private_dns_zone.this : zone.name]
# }

# output "dns_zone_virtual_network_link_ids" {
#   description = "The IDs of the private DNS zone virtual network links."
#   value       = [for link in azurerm_private_dns_zone_virtual_network_link.this : link.id]
# }

output "dns_zone_name" {
  description = "The names of the created private DNS zone."
  value       = azurerm_private_dns_zone.this.name
}