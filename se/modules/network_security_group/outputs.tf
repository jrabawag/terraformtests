output "id" {
  description = "Specifies the resource id of the network security group"
  value       = azurerm_network_security_group.nsg.id
}

# output "network_security_group_ids" {
#   description = "Contains a map of all created network security group IDs"
#   value = [ for nsg in azurerm_network_security_group.nsg : nsg.id ]
# }
