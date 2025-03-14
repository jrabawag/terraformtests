output "name" {
  description = "Specifies the name of the storage account"
  value       = azurerm_storage_account.storage_account.name
}

output "id" {
  description = "Specifies the resource id of the storage account"
  value       = azurerm_storage_account.storage_account.id
}

output "primary_access_key" {
  description = "Specifies the primary access key of the storage account"
  value       = azurerm_storage_account.storage_account.primary_access_key
}

output "container_ids" {
  value = { for name, container in azurerm_storage_container.sa_container : name => container.id }
  description = "Map of container IDs by name"
}

output "container_names" {
  value = { for name, container in azurerm_storage_container.sa_container : name => container.name }
  description = "Map of container IDs by name"
}

output "primary_blob_endpoint" {
  description = "Specifies the primary blob endpoint of the storage account"
  value       = azurerm_storage_account.storage_account.primary_blob_endpoint
}

output "primary_connection_string" {
  description = "Specifies the primary connection string of the storage account"
  value       = azurerm_storage_account.storage_account.primary_connection_string
}