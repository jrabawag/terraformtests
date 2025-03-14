output "name" {
  description = "Specifies the name of the container registry."
  value       = azurerm_management_lock.resource_lock.name
}

output "id" {
  description = "Specifies the resource id of the container registry."
  value       = azurerm_management_lock.resource_lock.id
}