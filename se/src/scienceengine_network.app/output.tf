# output "resource_group_ids" {
#   description = "Contains a map of the resource group names to their IDs from the module"
#   value       = module.resource_groups.resource_group_ids
# }

# output "log_analytics_workspaces" {
#   value = module.log_analytics_workspace.id
# }

# output "fw_pip_id" {
#   value = module.fw_public_ip.id
# }

# output "firewall_id" {
#   value = module.firewall.firewall_id
# }
# output "firewall_policy_id" {
#   value = module.firewall.firewall_policy_id
# }

# output "route_table_id" {
#   value = module.route.id
# }

# output "bastion_host_id" {
#   value = module.bastion_host.id
# }

# output "network_vnet_id" {
#   value = module.network.vnet_id
# }

# output "network_subnet_ids" {
#   description = "List of Subnet IDs"
#   value       = module.network.subnet_ids
# }


output "nsg_association_ids" {
  description = "The IDs of the NSG associations"
  value       = [for assoc in local.nsg_subnet_associations : assoc.subnet_id]
}




# # output "nsg_association_ids" {
# #   description = "List of NSG Subnet Associations"
# #   value       = module.nsg_association.nsg_association_ids
# # }


# # output "nsg_default_ids" {
# #   description = "List of NSG IDs"
# #   value = module.network_security_groups.network_security_group_ids
# # }



# output "nsg_subnet_associations" {
#   value = [
#     for subnet_name, subnet_id in module.network.subnet_ids : {
#       subnet_name            = subnet_name
#       subnet_id              = subnet_id
#       network_security_group = subnet_name == local.subnet_names["agw"] ? module.network_security_groups["agw"].id : module.network_security_groups["default"].id
#     }
#     if !(subnet_name == "AzureFirewallSubnet" || subnet_name == "AzureBastionSubnet")
#   ]

#   description = "List of subnet associations with their corresponding network security groups. Excludes AzureFirewallSubnet and AzureBastionSubnet."
# }