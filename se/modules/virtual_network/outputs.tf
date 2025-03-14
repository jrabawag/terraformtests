output "name" {
  description = "Specifies the name of the virtual network"
  value       = var.create_vnet ? azurerm_virtual_network.vnet[0].name : data.azurerm_virtual_network.vnet[0].name
}

output "vnet_id" {
  description = "Specifies the resource id of the virtual network"
  value       = var.create_vnet ? azurerm_virtual_network.vnet[0].id : data.azurerm_virtual_network.vnet[0].id
}

output "subnet_ids" {
  description = "Contains a list of the the resource id of the subnets"
  value       = { for subnet in azurerm_subnet.subnet : subnet.name => subnet.id }
}

output "subnet_names" {
  description = "Map of subnet names"
  value       = { for key, subnet in azurerm_subnet.subnet : key => subnet.name }
}