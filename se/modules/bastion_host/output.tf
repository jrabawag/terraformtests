# output "bastion_hosts" {
#   description = "Contains a map of all bastion hosts with their attributes"
#   value = {
#     for name, bastion in azurerm_bastion_host.bastion_host :
#     name => {
#       id             = bastion.id
#       name           = bastion.name
#       location       = bastion.location
#       resource_group = bastion.resource_group_name
#     }
#   }
# }


output "id" {
  description = "Contains the id of bastion hosts"
  value       = azurerm_bastion_host.bastion_host.id
}