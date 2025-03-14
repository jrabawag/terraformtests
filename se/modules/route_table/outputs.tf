# output "route_table_ids" {
#   description = "Contains a map of all created route tables with their IDs"
#   value       = { for rt in azurerm_route_table.rt : rt.name => rt.id }
# }

output "id" {
  description = "ID of the created route tables"
  value       = azurerm_route_table.route.id
}