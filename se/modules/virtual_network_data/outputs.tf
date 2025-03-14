output "vnet_name" {
  description = "Specifies the name of the virtual network"
  value       = data.azurerm_virtual_network.vnet.name
}

output "vnet_id" {
  description = "Specifies the resource id of the virtual network"
  value       = data.azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  description = "Contains a list of the the resource id of the subnets"
  value       = { for subnet in data.azurerm_subnet.subnet : subnet.name => subnet.id }
}
output "subnet_routing_ids" {
  description = "Contains a list of the the resource id of the subnets"
  value       = { for subnet in data.azurerm_subnet.subnet : subnet.name => subnet.route_table_id }
}

output "subnet_name" {
  description = "Contains a list of the the resource name of the subnets"
  value       = [for subnet in data.azurerm_subnet.subnet : subnet.name]
}
