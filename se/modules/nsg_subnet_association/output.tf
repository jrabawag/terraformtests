output "nsg_association_ids" {
  description = "The IDs of the NSG associations"
  value       = [for assoc in azurerm_subnet_network_security_group_association.nsg_association : assoc.id]
}
