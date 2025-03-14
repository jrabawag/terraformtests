output "vnet_names" {
  description = "Name of the virtual network"
  value       = var.create_vnet ? azurerm_virtual_network.vnet[0].name : data.azurerm_virtual_network.vnet[0].name
}

output "vnet_rg" {
  description = "Name of the virtual network"
  value       = var.create_vnet ? azurerm_virtual_network.vnet[0].name : data.azurerm_virtual_network.vnet[0].resource_group_name
}

output "vnet_ids" {
  description = "Resource ID of the virtual network"
  value       = var.create_vnet ? azurerm_virtual_network.vnet[0].id : data.azurerm_virtual_network.vnet[0].id
}

output "subnet_names" {
  description = "Map of subnet names to their resource IDs"
  value       = var.create_vnet ? { for key, subnet in azurerm_subnet.subnet : key => subnet.name } : { for key, subnet in data.azurerm_subnet.subnet : key => subnet.name }
}

# output "subnet_vnetids" {
#   description = "Map of subnet names to their resource IDs"
#   value       = var.create_vnet ? { for key, subnet in azurerm_subnet.subnet : key => subnet.name } : { for key, subnet in data.azurerm_subnet.subnet : key => subnet.virtual_network_id }
# }

output "subnet_ids" {
  description = "Map of subnet names to their resource IDs"
  value       = var.create_vnet ? { for key, subnet in azurerm_subnet.subnet : key => subnet.id } : { for key, subnet in data.azurerm_subnet.subnet : key => subnet.id }
}
