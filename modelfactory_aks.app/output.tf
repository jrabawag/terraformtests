output "resource_group_names" {
  description = "Map of formatted resource group names"
  value       = { for k, v in module.resource_groups : k => v.resource_groups }
}

# output "key_vaults" {
#   description = "List of created Key Vaults"
#   value       = { for k, v in azurerm_key_vault.keyvault : k => v.name }
# }

# output "log_analytics" {
#   description = "List of created Log analytics"
#   value       = { for k, v in azurerm_log_analytics_workspace.log_analytics : k => v.name }
# }

# # output "recovery_vaults" {
# #   description = "List of created Recovery Services Vaults"
# #   value       = { for k, v in azurerm_recovery_services_vault.rsv : k => v.name }
# # }

output "virtual_networks" {
  description = "List of created Virtual Networks"
  value       = { for k, v in azurerm_virtual_network.vnet : k => v.name }
}

output "subnet_cidrs" {
  description = "The dynamically calculated CIDRs for the subnets."
  value = local.subnet_list
}


# Subnets
output "subnet_names" {
  description = "List of subnet names"
  value       = { for k, v in azurerm_subnet.subnets : k => v.name }
}

# managed identities
output "user_assigned_identities" {
  description = "List of subnet names"
  value       = { for k, v in azurerm_user_assigned_identity.identity : k => v.name }
}

# AKS
output "aks_clusters" {
  description = "Aggregated details of the AKS clusters."
   value = {
     for key, cluster in module.aks_clusters : key => cluster.aks_cluster_details
  }
}

# Node pools
output "aks_node_pools_details" {
  description = "Details of all AKS node pools excluding default node pools"
  value = {
    additional_node_pools = {
      for node_pool_key, node_pool in module.aks_node_pools : node_pool_key => {
        cluster_id = node_pool.node_pool_details.cluster_id
        name       = node_pool.node_pool_details.name
        vm_size    = node_pool.node_pool_details.vm_size
        node_count = node_pool.node_pool_details.node_count
      }
      if node_pool.node_pool_details.name != module.aks_clusters
    }
  }
}

# DNS
output "aks_private_dns" {
  description = "Details of the private DNS zones and their associated links for AKS."
  value = {
    for key, dns in module.aks_private_dns : key => {
      dns_name            = dns.name
      resource_group_name = dns.resource_group_name
      virtual_network_links = {
        for link_key, link in dns.virtual_network_links : link_key => {
          link_name            = link.name
          link_vnet            = link.virtual_network_id
          registration_enabled = link.registration_enabled
        }
      }
    }
  }
}

# A records FQDNs
output "aks_private_dns_fqdns" {
  description = "FQDNs of the private DNS A records for AKS."
  value = {
    for key, dns in module.aks_private_dns_a_records : key => dns.fqdn
  }
}

#Management VM
output "mgmt_vm_details" {
  description = "Details of the Management VM"
  value = {
    management_vm = {
      for region, vm in module.aks_mgmt_vm_ubuntu : region => merge(
        {
          name     = vm.name
          vm_user  = vm.username
          identity = vm.identity
        },
        module.nic_deploy_vm[region] != null ? {
          nic_id     = module.nic_deploy_vm[region].nic_id
          private_ip = module.nic_deploy_vm[region].private_ip_address
        } : {}
      )
    }
  }
  # sensitive = true
}

output "roleass" {
  value = azurerm_user_assigned_identity.identity["uks-aks"].principal_id
}