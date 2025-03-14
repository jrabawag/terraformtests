output "resource_group_ids" {
  description = "Contains a list of the resource object_id of the resource groups"
  value       = { for resource_group in azurerm_resource_group.this : resource_group.name => resource_group.id }
}