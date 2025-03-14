output "object_ids" {
  description = "Contains a list of the resource object_id of the groups"
  value       = { for group in azurerm_key_vault_access_policy.group : group.object_id => group.id }
}
