#SSH keys
module "ssh_keys" {
  source = "../../modules/ssh_key"
  for_each = toset([
    "aksnodesshkey",
    "mgmtserversshkey"
  ])
  key_vault_id = azurerm_key_vault.keyvault[local.default_data_region].id
  sshkey_name  = each.value
}

# Resource Groups
#✅ Check if aks rg are to create in another pipeline
module "resource_groups" {
  source   = "../../modules/resource_group"
  for_each = var.resource_groups
  tags     = local.default_tags
  resource_groups = [
    for rg_name in each.value.name : {
      name     = "rg-${var.project}-${each.key}-${rg_name}-${lower(var.environment)}"
      location = local.locations_map[each.key]
    }
  ]
}

# Subnets
#✅ Check if aks subnets are to create in another pipeline
#✅ Check if we'll use cidr or manual input
# resource "azurerm_subnet" "subnets" {
#   for_each             = { for subnet in local.subnet_list : subnet.key => subnet }  
#   name                 = "${each.value.name}Subnet"
#   resource_group_name  = "rg-${var.project}-${each.value.region}-network-${lower(var.environment)}"
#   virtual_network_name = "vnet-${var.project}-${each.value.region}-${lower(var.environment)}"
#   address_prefixes     = [each.value.cidr]
# }

resource "azurerm_subnet" "subnets" {
  for_each             = local.subnet_list  
  name                 = "${each.key}Subnet"
  resource_group_name  = "rg-${var.project}-${each.value.region}-network-${lower(var.environment)}"
  virtual_network_name = "vnet-${var.project}-${each.value.region}-${lower(var.environment)}"
  address_prefixes     = [each.value.cidr]
}


resource "azurerm_route_table" "rt" {
  name                = "aksrt"
  location            = "uksouth"
  resource_group_name = "rg-${var.project}-uks-network-${lower(var.environment)}"
  # route {
  #   name                   = "kubenetfw_fw_r"
  #   address_prefix         = "0.0.0.0/0"
  #   next_hop_type          = "VirtualAppliance"
  #   next_hop_in_ip_address = var.firewall_private_ip
  # }

  lifecycle {
    ignore_changes = [
      tags,
      route
    ]
  }
}

resource "azurerm_role_assignment" "route_table_permission" {
  for_each = var.aks_compute
  principal_id   = azurerm_user_assigned_identity.identity["${each.key}-${each.value.identity}"].principal_id
  role_definition_name = "Network Contributor"
  scope         = azurerm_route_table.rt.id
  depends_on = [ azurerm_route_table.rt, azurerm_user_assigned_identity.identity ]
}



# Identities
#✅ Check if aks identities are to create in another pipeline
resource "azurerm_user_assigned_identity" "identity" {
  for_each = { for entry in flatten([
    for region, cfg in var.identities : [
      for identity in cfg.names : {
        key            = "${region}-${identity}"
        region         = region
        identity_name  = identity
        resource_group = cfg.resource_group
  }]]) : entry.key => entry }
  name                = "uai-${var.project}-${each.key}-${lower(var.environment)}"
  resource_group_name = "rg-${var.project}-${each.value.region}-${each.value.resource_group}-${lower(var.environment)}"
  location            = local.locations_map[each.value.region]
}

#---

## AKS
#✅ Check if AKS from diff regions will use same creds

# Clusters
module "aks_clusters" {
  for_each                = { for key, value in var.aks_compute : key => value }
  source                  = "../../modules/aks"
  name                    = "aks-${var.project}-${each.key}-${each.value.cluster_name}-${lower(var.environment)}"
  location                = local.locations_map[each.key]
  resource_group_name     = module.resource_groups[each.key].resource_groups["rg-${var.project}-${each.key}-${each.value.resource_group}-${lower(var.environment)}"].name
  kubernetes_version      = each.value.node_pool.default.kubernetes_version
  dns_prefix              = lower(each.value.cluster_name)
  private_cluster_enabled = true
  private_dns_zone_id     = module.aks_private_dns[each.value.private_dns_zone].id
  sku_tier     = each.value.sku_tier
  support_plan = "AKSLongTermSupport"

  default_node_pool_name                   = lower("aks${each.value.node_pool.default.name}") #✅ 1-12 lowercase
  default_node_pool_vm_size                = each.value.node_pool.default.vm_size
  default_node_pool_availability_zones     = each.value.node_pool.default.availability_zones
  default_node_pool_node_labels            = each.value.node_pool.default.node_labels
  default_node_pool_node_taints            = each.value.node_pool.default.node_taints
  default_node_pool_enable_auto_scaling    = each.value.node_pool.default.enable_auto_scaling
  default_node_pool_enable_host_encryption = false
  default_node_pool_enable_node_public_ip  = false
  default_node_pool_max_pods               = each.value.node_pool.default.max_pods
  default_node_pool_max_count              = each.value.node_pool.default.enable_auto_scaling ? each.value.node_pool.default.max_count : null
  default_node_pool_min_count              = each.value.node_pool.default.enable_auto_scaling ? each.value.node_pool.default.min_count : null
  default_node_pool_node_count             = each.value.node_pool.default.node_count
  default_node_pool_os_disk_type           = each.value.node_pool.default.os_disk_type
  vnet_subnet_id                           = azurerm_subnet.subnets[each.value.node_pool.default.subnet].id

  aks_admin_username         = each.value.admin_username
  aks_ssh_public_key         = module.ssh_keys["aksnodesshkey"].ssh_public_key
  identity_ids               = [azurerm_user_assigned_identity.identity["${each.key}-${each.value.identity}"].id]
  network_plugin             = each.value.network_plugin == "kubenet" ? "kubenet" : "azure"
  network_plugin_mode        = each.value.network_plugin == "kubenet" ? null : "overlay"
  network_policy             = each.value.network_plugin == "kubenet" ? "calico" : "azure"
  outbound_type              = each.value.outbound_type
  network_docker_bridge_cidr = "172.17.0.1/16"
  network_service_cidr       = "10.0.0.0/16"
  network_dns_service_ip     = "10.0.0.10"

  http_application_routing_enabled  = false
  azure_policy_enabled              = true
  microsoft_defender_enabled        = true
  log_analytics_workspace_id        = azurerm_log_analytics_workspace.log_analytics["${each.value.log_analytics}"].id
  role_based_access_control_enabled = each.value.role_based_access_control_enabled
  tenant_id                         = data.azurerm_client_config.current.tenant_id
  admin_group_object_ids            = [] #data.azuread_group.groups.*.object_id
  azure_rbac_enabled                = each.value.azure_rbac_enabled
  tags                              = local.default_tags

  depends_on = []
}
# #✅
# # Check if needed
# #             --enable-oidc-issuer \
# #             --enable-workload-identity \
# #             --enable-addons monitoring \

# Node Pools
module "aks_node_pools" {
  source = "../../modules/aks_node_pool"
  for_each = {
    for np in flatten([
      for cluster_key, cluster_value in var.aks_compute : [
        for node_pool_key, node_pool in cluster_value.node_pool : {
          cluster_key   = cluster_key
          node_pool_key = node_pool_key
          node_pool     = node_pool
        }
      ]
    ]) : "${np.cluster_key}-${np.node_pool_key}" => np
    if np.node_pool_key != "default"
  }
  kubernetes_cluster_id    = module.aks_clusters[each.value.cluster_key].id
  name                     = lower("aks${each.value.node_pool.name}") #✅ 1-12 lowercase
  vm_size                  = each.value.node_pool.vm_size
  node_taints              = each.value.node_pool.node_taints
  node_labels              = each.value.node_pool.node_labels
  orchestrator_version     = each.value.node_pool.kubernetes_version
  max_pods                 = each.value.node_pool.max_pods
  node_count               = each.value.node_pool.node_count
  enable_auto_scaling      = each.value.node_pool.enable_auto_scaling
  max_count                = each.value.node_pool.enable_auto_scaling ? each.value.node_pool.max_count : null
  min_count                = each.value.node_pool.enable_auto_scaling ? each.value.node_pool.min_count : null
  availability_zones       = each.value.node_pool.availability_zones
  node_pool_vnet_subnet_id = azurerm_subnet.subnets[each.value.node_pool.subnet].id
  depends_on               = [module.aks_clusters]
}

#---

### DNS
# Private DNS
module "aks_private_dns" {
  source = "../../modules/private_dns_zone"
  for_each = { for key, dns in var.private_dns : key => {
      dns_name = lower("${var.project}.privatelink.${local.locations_map[dns.region]}.azmk8s.io")
      rgname   = "rg-${var.project}-${dns.region}-network-${lower(var.environment)}"
      virtual_networks_to_link = { for vnet in dns.link.vnets : vnet => {
          link_name            = "link_to_${vnet}_vnet"
          virtual_network_id   = azurerm_virtual_network.vnet[vnet].id
          registration_enabled = dns.link.registration_enabled
        }
      }
      existing = dns.existing
    }
  }
  name                     = each.value.dns_name
  resource_group_name      = each.value.rgname
  virtual_networks_to_link = each.value.virtual_networks_to_link
  existing                 = each.value.existing
}
# A records
module "aks_private_dns_a_records" {
    source                  = "../../modules/private_dns_a_record"
    for_each                = { for key, value in var.aks_compute : key => value }
    dns_a_name              = lower("${each.key}-${each.value.cluster_name}")
    dns_zone_name           = module.aks_private_dns[each.value.private_dns_zone].name
    dns_resource_group_name = module.aks_private_dns[each.value.private_dns_zone].resource_group_name
    ttl                     = 10
    records                 = [module.aks_clusters[each.key].aks_cluster_details.private_fqdn]  # [cidrhost(var.subnet_address_prefixes, -2)]

    depends_on = [
      module.aks_private_dns,
      module.aks_clusters
    ]
}

# ## Create PasX Private DNS CName records
# module "pasx_private_dns_cname_records" {
#     source = "../../modules/private_dns_cname_record"

#     for_each = toset(["alertmanager", "argocd", "cups", "grafana", "argocdgrpc", "kibana", "prometheus", "k10", "notary", "registry"])


#     dns_cname               = each.value
#     dns_zone_name           = module.pasx_private_dns["pasx"].name
#     dns_resource_group_name = module.pasx_private_dns["pasx"].resource_group_name
#     ttl                     = 10
#     record                 = "pasx.pasx${lower(var.SITE)}-${var.envi}.${var.domain}"

#     depends_on = [
#       module.pasx_private_dns["pasx"]
#     ]
# }


#---

### Management VM
# VM PWD
module "random_password" {
  source = "../../modules/random_password"
}
module "mgmt_vm_password" {
  source                 = "../../modules/key_vault_secret"
  key_vault_secret_name  = "aks-mgmt-vm-password"
  key_vault_secret_value = module.random_password.deploy_vm_password
  key_vault_id           = azurerm_key_vault.keyvault["uks"].id
  depends_on = [module.random_password]
}
# NIC
module "nic_deploy_vm" {
  source              = "../../modules/nic"
  for_each            = var.mgmt_vm
  nic_name            = "${var.mgmt_vm[each.key].name}-nic"
  location            = local.locations_map[each.key]
  resource_group_name = module.resource_groups[each.key].resource_groups["rg-${var.project}-${each.key}-${var.mgmt_vm[each.key].resource_group}-${lower(var.environment)}"].name
  subnet_id           = azurerm_subnet.subnets["${var.mgmt_vm[each.key].subnet}"].id
  private_ip_address  = tostring(cidrhost(azurerm_subnet.subnets["${var.mgmt_vm[each.key].subnet}"].address_prefixes[0], 4))
}
# VM
module "aks_mgmt_vm_ubuntu" {
  source                       = "../../modules/ubuntu_virtual_machine"
  for_each                     = var.mgmt_vm
  name                         = "vm-${var.project}-${each.key}-${var.mgmt_vm[each.key].name}-${lower(var.environment)}" #var.mgmt_vm[each.key].name
  location                     = local.locations_map[each.key]
  resource_group_name          = module.resource_groups[each.key].resource_groups["rg-${var.project}-${each.key}-${var.mgmt_vm[each.key].resource_group}-${lower(var.environment)}"].name
  nic_ids                      = [module.nic_deploy_vm[each.key].nic_id]
  size                         = var.mgmt_vm[each.key].size
  os_disk_storage_account_type = var.mgmt_vm[each.key].os_disk_storage_account_type
  vm_user                      = var.mgmt_vm[each.key].username
  deploy_vm_password           = module.mgmt_vm_password.secret_value
  disable_password_auth        = "false"
  admin_ssh_public_key         = module.ssh_keys["mgmtserversshkey"].ssh_public_key
  zone                         = var.mgmt_vm[each.key].zone

  inline_base64_script = var.mgmt_vm[each.key].vm_script

  depends_on = [
    module.nic_deploy_vm,
    module.ssh_keys,
    module.mgmt_vm_password
  ]
}




# data "azurerm_shared_image" "nnlinux" {
#   name                = var.gallery_nn_linux_image
#   gallery_name        = var.gallery_name
#   resource_group_name = "rg-PSNetLinux-${var.REGION}-PRD"
#   provider            = azurerm.gallery_linux
# }