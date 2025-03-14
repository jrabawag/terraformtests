output "group_object_ids" {
  description = "Contains a list of the resource object_id of the groups"
  value       = module.group_policies.object_ids
}

output "user_object_ids" {
  description = "Contains a list of the resource object_id of the groups"
  value       = module.user_policies.object_ids
}

output "key_vault_id" {
  description = "Contains a list of the resource object_id of the groups"
  value       = module.key_vault.id
}
