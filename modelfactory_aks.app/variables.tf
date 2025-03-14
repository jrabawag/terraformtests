variable "aad_tenant_id" {
  description = "active directory tenant id"
  type        = string
  default     = "fdfed7bd-9f6a-44a1-b694-6e39c468c150"
}
variable "project" {
  description = "The name of the project"
  type        = string
}
variable "shortproject" {
  description = "The shortname of the project"
  type        = string
}
variable "environment" {
  description = "The environment in which this configuration is applied"
  type        = string
}

variable "region_kvsecrets" {
  description = "The default region for existing resources"
  type        = string
  default     = "weu" 
}

# DATA
variable "data" {
  type = object({
    network = map(object({
      resource_group = string
    }))
    keyvault = map(object({
      name           = string
      resource_group = string
    }))
    log_analytics = map(object({
      name           = string
      resource_group = string
    }))
  })
}

# DNS
variable "private_dns" {
  type = map(object({
    existing       = bool
    resource_group = string
    region         = string
    link = object({
      vnets             = list(string)
      registration_enabled = bool
    })
  }))
}

# Subnets
# variable "subnets" {
#   type = map(object({
#     create_subnets = bool
#     subnets        = list(string)
#     # network         = string
#   }))
# }

# Subnets
variable "subnets" {
  type = map(object({
    existing      = bool
    name        = string
    network     = string
    mask        = number
  }))
}

# Resource Groups
variable "resource_groups" {
  type = map(object({
    name     = list(string)
    existing = bool
  }))
}

# Identities
variable "identities" {
  type = map(object({
    names          = list(string)
    resource_group = string
  }))
}

# AKS Management VM
variable "mgmt_vm" {
  type = map(object({
    name           = string
    subnet         = string
    resource_group = string
    size           = string
    username       = string
    os_disk_storage_account_type = optional(string, "Standard_LRS")
    zone           = optional(string, "1")
    vm_script = optional(string, "")
  }))
}


# validation {
#   condition = alltrue([
#     for k in keys(var.region_config) : contains(["uks", "weu"], k)
#   ])
#   error_message = "Each region must be either 'uks' (UK South) or 'weu' (West Europe)."
# }


# AKS
variable "aks_compute" {
  description = "Configuration for multiple AKS clusters"
  type = map(object({
    cluster_name                      = string
    private_dns_zone                  = string
    log_analytics                     = string
    resource_group                    = string
    identity                          = string
    sku_tier                          = optional(string, "Free")
    network_plugin                    = optional(string, "kubenet")
    outbound_type                     = optional(string, "userDefinedRouting")
    http_application_routing_enabled  = optional(bool, false)
    admin_username                    = optional(string, "azadmin")
    automatic_channel_upgrade         = optional(string, "patch") #stable
    role_based_access_control_enabled = optional(bool, true)
    azure_rbac_enabled                = optional(bool, true)

    node_pool = map(object({
      name                = string
      subnet              = string
      vm_size             = optional(string, "Standard_D8ds_v5")
      node_taints         = optional(list(string), [])
      node_labels         = optional(map(string), {})
      kubernetes_version  = optional(string, "1.30.6")
      max_pods            = optional(number, 110)
      enable_auto_scaling = optional(bool, true)
      node_count          = optional(number, 2)
      os_disk_type        = optional(string, "Ephemeral")
      min_count           = optional(number, 2)
      max_count           = optional(number, 3)
      availability_zones  = optional(list(string), ["1", "2", "3"])
    }))
  }))
  validation {
    condition = alltrue([
      for k, v in var.aks_compute : contains(["uks", "weu"], k)
    ])
    error_message = "Each AKS cluster must be located in either 'UK South' or 'West Europe'."
  }
}




# az aks create \
#             --resource-group ${{ variables.mf_rg }} \
#             --name ${{ variables.aks_cluster_name }} \
#             --location uksouth \


#             --load-balancer-sku Standard \

#             --assign-identity "/subscriptions/86d23032-62b7-4f7f-9bf2-1a6474f68440/resourceGroups/${{ variables.mf_rg }}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${{ variables.mf_mi }}" \
#             --enable-aad \


#             --auto-upgrade-channel patch \
#             --node-os-upgrade-channel NodeImage \
#             --node-osdisk-size 128 \
#             --node-osdisk-type Ephemeral \
#             --max-pods 110 \

#             --workspace-resource-id "/subscriptions/86d23032-62b7-4f7f-9bf2-1a6474f68440/resourceGroups/rg-ModelFactory-weu-log-tst/providers/Microsoft.OperationalInsights/workspaces/${{ variables.mf_la }}" \
#             --generate-ssh-keys
















# validation {
#   condition = alltrue([
#     for k, v in var.aks_compute : contains(["uksouth", "westeurope"], v.region)
#   ])
#   error_message = "Each AKS cluster must be located in either 'UK South' or 'West Europe'."
# }
#}


# variable "region" {
#   description = "Specifies the region for the resource group and all the resources"
#   default     = "west Europe"
#   type        = string
# }

# # Network
# variable "networks" {
#   type = map(object({
#     create_rg      = bool
#     create_vnet    = bool
#     create_subnets = bool
#     subnets = optional(map(object({
#       subnet_name                                    = string
#       address_prefixes                               = list(string)
#       service_endpoints                              = optional(list(string), [])
#       enforce_private_link_endpoint_network_policies = optional(string, "Disabled")
#       enforce_private_link_service_network_policies  = optional(bool, false)
#       postgres_service_deligation                    = optional(bool, false)
#     })), {})
#   }))
#   validation {
#     condition = alltrue([
#       for _, v in values(var.networks) :
#       alltrue([
#         for _, subnet in values(v.subnets) : (
#           contains(["Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], subnet.enforce_private_link_endpoint_network_policies)
#         )
#       ])
#     ])
#     error_message = "Each subnet's enforce_private_link_endpoint_network_policies must be one of ['Disabled', 'Enabled', 'NetworkSecurityGroupEnabled', 'RouteTableEnabled']."
#   }
# }

# # ResourceGroup
# variable "resource_groups" {
#   description = "Map of resource groups with their attributes"
#   type = map(object({
#     resource_group_name = string
#     region            = string
#     existing            = bool
#   }))
# }

# # Log Analytics
# variable "log_analytics" {
#   description = "Map of resource groups with their attributes"
#   type = map(object({
#     workspace_name      = string
#     resource_group_name = string
#     region            = string
#     existing            = bool
#     solution_plan_map   = optional(map(object({ 
#       product   = string
#       publisher = string
#     })), {
#       ContainerInsights = {
#         product   = "OMSGallery/ContainerInsights"
#         publisher = "Microsoft"
#       }
#     })
#   }))
# }

# variable "solution_plan_map" {
#   default = {
#     ContainerInsights = {
#       product   = "OMSGallery/ContainerInsights"
#       publisher = "Microsoft"
#     }
#   }
#   type = map(any)
# }

# # Identities
# variable "identities" {
#   description = "Map of resource groups with their attributes"
#   type = map(object({
#     resource_group_name = string
#     identity_name       = string
#     region            = string
#     existing            = bool
#   }))
# }







# variable "aks_cluster_name" {
#   description = "(Required) Specifies the name of the AKS cluster."
#   default     = "NovoAks"
#   type        = string
# }

# variable "kubernetes_version" {
#   description = "Specifies the AKS Kubernetes version"
#   default     = "1.21.1"
#   type        = string
# }

# variable "sku_tier" {
#   description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Free."
#   default     = "Free"
#   type        = string
# }

# variable "vnets" {
#   description = "A map of virtual networks with their resource group names and VNet names for different regions."
#   type = map(object({
#     vnet_resource_group_name = string
#     vnet_name                = string
#   }))
# }

# # Resource Group(s)
# variable "vnet_resource_group_name" {
#   description = "Specifies the resource group name of the VNET"
#   default     = "NovoVnetRG"
#   type        = string
# }
# variable "aks_resource_group_name" {
#   description = "Specifies the resource group name of the AKS Cluster"
#   default     = "NovoAksRG"
#   type        = string
# }



# variable "aks_identity_name" {
#   description = "(Required) Specifies the name of the AKS cluster Identiy."
#   type        = string
# }

# variable "aks_identity_resource_group_name" {
#   description = "(Required) Specifies the name of the AKS cluster Identiy resource group."
#   type        = string
# }


# # LOG Analytics
# variable "log_analytics_workspace_name" {
#   description = "Specifies the name of the log analytics workspace"
#   default     = "NovoAksWorkspace"
#   type        = string
# }

# variable "log_analytics_retention_days" {
#   description = "Specifies the number of days of the retention policy"
#   type        = number
#   default     = 30
# }

# variable "solution_plan_map" {
#   description = "Specifies solutions to deploy to log analytics workspace"
#   default = {
#     ContainerInsights = {
#       product   = "OMSGallery/ContainerInsights"
#       publisher = "Microsoft"
#     }
#   }
#   type = map(any)
# }

# # Network
# variable "bastion_subnet_address_prefix" {
#   description = "Specifies the address prefix of the firewall subnet"
#   default     = ["10.1.1.0/24"]
#   type        = list(string)
# }

# variable "firewall_subnet_address_prefix" {
#   description = "Specifies the address prefix of the firewall subnet"
#   default     = ["10.1.0.0/24"]
#   type        = list(string)
# }

# variable "aks_vnet_name" {
#   description = "Specifies the name of the AKS subnet"
#   default     = "AksVNet"
#   type        = string
# }

# variable "aks_vnet_address_space" {
#   description = "Specifies the address prefix of the AKS subnet"
#   default     = ["10.0.0.0/16"]
#   type        = list(string)
# }

# variable "vm_subnet_name" {
#   description = "Specifies the name of the jumpbox subnet"
#   default     = "VmSubnet"
#   type        = string
# }

# variable "vm_subnet_address_prefix" {
#   description = "Specifies the address prefix of the jumbox subnet"
#   default     = ["10.0.8.0/21"]
#   type        = list(string)
# }

# variable "default_node_pool_subnet_name" {
#   description = "Specifies the name of the subnet that hosts the default node pool"
#   default     = "SystemSubnet"
#   type        = string
# }

# variable "default_node_pool_subnet_address_prefix" {
#   description = "Specifies the address prefix of the subnet that hosts the default node pool"
#   default     = ["10.0.0.0/21"]
#   type        = list(string)
# }

# # Firewall
# variable "firewall_enable" {
#   description = "(Optional) Specifies the deployment of the bastion host"
#   default     = true
#   type        = bool
# }

# variable "firewall_name" {
#   description = "Specifies the name of the Azure Firewall"
#   default     = "NovoFirewall"
#   type        = string
# }

# variable "firewall_sku_tier" {
#   description = "Specifies the SKU tier of the Azure Firewall"
#   default     = "Standard"
#   type        = string
# }

# variable "firewall_threat_intel_mode" {
#   description = "(Optional) The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert, Deny. Defaults to Alert."
#   default     = "Alert"
#   type        = string

#   validation {
#     condition     = contains(["Off", "Alert", "Deny"], var.firewall_threat_intel_mode)
#     error_message = "The threat intel mode is invalid."
#   }
# }

# variable "firewall_zones" {
#   description = "Specifies the availability zones of the Azure Firewall"
#   default     = ["1", "2", "3"]
#   type        = list(string)
# }

# # BASTION
# variable "bastion_host_enable" {
#   description = "(Optional) Specifies the deployment of the bastion host"
#   default     = true
#   type        = bool
# }


# variable "bastion_host_name" {
#   description = "(Optional) Specifies the name of the bastion host"
#   default     = "NovoBastionHost"
#   type        = string
# }

# variable "tags" {
#   description = "(Optional) Specifies tags for all the resources"
#   default = {
#     createdWith = "Terraform"
#   }
# }

# # StorageAccount (Boot-Diagnostic):
# variable "storage_account_kind" {
#   description = "(Optional) Specifies the account kind of the storage account"
#   default     = "StorageV2"
#   type        = string

#   validation {
#     condition     = contains(["Storage", "StorageV2"], var.storage_account_kind)
#     error_message = "The account kind of the storage account is invalid."
#   }
# }

# variable "storage_account_tier" {
#   description = "(Optional) Specifies the account tier of the storage account"
#   default     = "Standard"
#   type        = string

#   validation {
#     condition     = contains(["Standard", "Premium"], var.storage_account_tier)
#     error_message = "The account tier of the storage account is invalid."
#   }
# }

# variable "storage_account_replication_type" {
#   description = "(Optional) Specifies the replication type of the storage account"
#   default     = "LRS"
#   type        = string

#   validation {
#     condition     = contains(["LRS", "ZRS", "GRS", "GZRS", "RA-GRS", "RA-GZRS"], var.storage_account_replication_type)
#     error_message = "The replication type of the storage account is invalid."
#   }
# }

# # ARC
# variable "acr_name" {
#   description = "Specifies the name of the container registry"
#   type        = string
#   default     = "NovoAcr"
# }

# variable "acr_identity_name" {
#   description = "(Required) Specifies the name of the Container Registry Identiy."
#   type        = string
# }

# variable "acr_identity_resource_group_name" {
#   description = "(Required) Specifies the name of the Container Registry Identiy resource group."
#   type        = string
# }


# variable "acr_sku" {
#   description = "Specifies the name of the container registry"
#   type        = string
#   default     = "Premium"

#   validation {
#     condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
#     error_message = "The container registry sku is invalid."
#   }
# }

# variable "acr_admin_enabled" {
#   description = "Specifies whether admin is enabled for the container registry"
#   type        = bool
#   default     = true
# }

# variable "acr_georeplication_locations" {
#   description = "(Optional) A list of Azure locations where the container registry should be geo-replicated."
#   type        = list(string)
#   default     = []
# }

# # KeyVault
# variable "key_vault_name" {
#   description = "Specifies the name of the key vault."
#   type        = string
#   default     = "NovoAksKeyVault"
# }

# variable "key_vault_sku_name" {
#   description = "(Required) The Name of the SKU used for this Key Vault. Possible values are standard and premium."
#   type        = string
#   default     = "standard"

#   validation {
#     condition     = contains(["standard", "premium"], var.key_vault_sku_name)
#     error_message = "The sku name of the key vault is invalid."
#   }
# }

# variable "key_vault_enabled_for_deployment" {
#   description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to false."
#   type        = bool
#   default     = true
# }

# variable "key_vault_enabled_for_disk_encryption" {
#   description = " (Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Defaults to false."
#   type        = bool
#   default     = true
# }

# variable "key_vault_enabled_for_template_deployment" {
#   description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. Defaults to false."
#   type        = bool
#   default     = true
# }

# variable "key_vault_enable_rbac_authorization" {
#   description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions. Defaults to false."
#   type        = bool
#   default     = true
# }

# variable "key_vault_purge_protection_enabled" {
#   description = "(Optional) Is Purge Protection enabled for this Key Vault? Defaults to false."
#   type        = bool
#   default     = true
# }

# variable "key_vault_soft_delete_retention_days" {
#   description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days."
#   type        = number
#   default     = 30
# }

# variable "key_vault_bypass" {
#   description = "(Required) Specifies which traffic can bypass the network rules. Possible values are AzureServices and None."
#   type        = string
#   default     = "AzureServices"

#   validation {
#     condition     = contains(["AzureServices", "None"], var.key_vault_bypass)
#     error_message = "The valut of the bypass property of the key vault is invalid."
#   }
# }

# variable "key_vault_default_action" {
#   description = "(Required) The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids. Possible values are Allow and Deny."
#   type        = string
#   default     = "Allow"

#   validation {
#     condition     = contains(["Allow", "Deny"], var.key_vault_default_action)
#     error_message = "The value of the default action property of the key vault is invalid."
#   }
# }

# AKS GLOBAL

#   validation {
#     condition     = contains(["Free", "Paid"], var.sku_tier)
#     error_message = "The sku tier is invalid."
#   }
# }

# variable "network_docker_bridge_cidr" {
#   description = "Specifies the Docker bridge CIDR"
#   default     = "172.17.0.0/16"
#   type        = string
# }

# variable "network_dns_service_ip" {
#   description = "Specifies the DNS service IP"
#   default     = "10.2.0.10"
#   type        = string
# }

# variable "network_service_cidr" {
#   description = "Specifies the service CIDR"
#   default     = "10.2.0.0/24"
#   type        = string
# }

# variable "network_plugin" {
#   description = "Specifies the network plugin of the AKS cluster"
#   default     = "azure"
#   type        = string
# }

# variable "outbound_type" {
#   description = "(Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer."
#   type        = string
#   default     = "userDefinedRouting"

#   validation {
#     condition     = contains(["loadBalancer", "userDefinedRouting"], var.outbound_type)
#     error_message = "The outbound type is invalid."
#   }
# }


# variable "automatic_channel_upgrade" {
#   description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, and stable."
#   default     = "stable"
#   type        = string

#   validation {
#     condition     = contains(["patch", "rapid", "stable"], var.automatic_channel_upgrade)
#     error_message = "The upgrade mode is invalid."
#   }
# }

# variable "role_based_access_control_enabled" {
#   description = "(Required) Is Role Based Access Control Enabled? Changing this forces a new resource to be created."
#   default     = true
#   type        = bool
# }

# variable "admin_group_object_ids" {
#   description = "(Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster."
#   default     = ["6e5de8c1-5a4b-409b-994f-0706e4403b77", "78761057-c58c-44b7-aaa7-ce1639c6c4f5"]
#   type        = list(string)
# }

# variable "azure_rbac_enabled" {
#   description = "(Optional) Is Role Based Access Control based on Azure AD enabled?"
#   default     = true
#   type        = bool
# }

# variable "aci_connector_linux" {
#   description = "Specifies the ACI connector addon configuration."
#   type = object({
#     enabled     = bool
#     subnet_name = string
#   })
#   default = {
#     enabled     = false
#     subnet_name = null
#   }
# }

# variable "azure_policy_enabled" {
#   description = "Specifies the Azure Policy addon configuration."
#   type        = bool
#   default     = false
# }

# variable "microsoft_defender_enabled" {
#   description = "Enable Microsoft Defener addon"
#   type        = bool
#   default     = false
# }


# variable "http_application_routing_enabled" {
#   description = "Specifies the HTTP Application Routing addon configuration."
#   type        = bool
#   default     = false
# }

# variable "kube_dashboard" {
#   description = "Specifies the Kubernetes Dashboard addon configuration."
#   type = object({
#     enabled = bool
#   })
#   default = {
#     enabled = false
#   }
# }

# # AKS Application Gateway Ingress Controller
# variable "ingress_application_gateway" {
#   description = "Specifies the Application Gateway Ingress Controller addon configuration."
#   type = object({
#     enabled      = bool
#     gateway_id   = string
#     gateway_name = string
#     subnet_cidr  = string
#     subnet_id    = string
#   })
#   default = {
#     enabled      = false
#     gateway_id   = null
#     gateway_name = null
#     subnet_cidr  = null
#     subnet_id    = null
#   }
# }

# AKS Cluster DEFAULT_NODE_POOL
# variable "default_node_pool_name" {
#   description = "Specifies the name of the default node pool"
#   default     = "system"
#   type        = string
# }

# variable "default_node_pool_vm_size" {
#   description = "Specifies the vm size of the default node pool"
#   default     = "Standard_F8s_v2"
#   type        = string
# }

# variable "default_node_pool_availability_zones" {
#   description = "Specifies the availability zones of the default node pool"
#   default     = ["1", "2", "3"]
#   type        = list(string)
# }
# variable "default_node_pool_enable_auto_scaling" {
#   description = "(Optional) Whether to enable auto-scaler. Defaults to false."
#   type        = bool
#   default     = true
# }

# variable "default_node_pool_enable_host_encryption" {
#   description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
#   type        = bool
#   default     = false
# }

# variable "default_node_pool_max_pods" {
#   description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
#   type        = number
#   default     = 50
# }

# variable "default_node_pool_node_labels" {
#   description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
#   type        = map(any)
#   default     = {}
# }

# variable "default_node_pool_node_taints" {
#   description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
#   type        = list(string)
#   default     = []
# }

# variable "default_node_pool_os_disk_type" {
#   description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
#   type        = string
#   default     = "Ephemeral"
# }

# variable "default_node_pool_max_count" {
#   description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
#   type        = number
#   default     = 10
# }

# variable "default_node_pool_min_count" {
#   description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
#   type        = number
#   default     = 3
# }

# variable "default_node_pool_enable_node_public_ip" {
#   description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
#   type        = bool
#   default     = false
# }

# variable "default_node_pool_node_count" {
#   description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
#   type        = number
#   default     = 3
# }

# # central_NODE_POOL
# variable "central_node_pool_name" {
#   description = "(Required) Specifies the name of the node pool."
#   type        = string
# }

# variable "central_node_pool_vm_size" {
#   description = "(Required) The SKU which should be used for the Virtual Machines used in this Node Pool. Changing this forces a new resource to be created."
#   type        = string
#   default     = "Standard_F8s_v2"
# }

# variable "central_node_pool_availability_zones" {
#   description = "(Optional) A list of Availability Zones where the Nodes in this Node Pool should be created in. Changing this forces a new resource to be created."
#   type        = list(string)
#   default     = ["1", "2", "3"]
# }

# variable "central_node_pool_enable_auto_scaling" {
#   description = "(Optional) Whether to enable auto-scaler. Defaults to false."
#   type        = bool
#   default     = true
# }

# variable "central_node_pool_enable_host_encryption" {
#   description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
#   type        = bool
#   default     = false
# }

# variable "central_node_pool_enable_node_public_ip" {
#   description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
#   type        = bool
#   default     = false
# }

# variable "central_node_pool_max_pods" {
#   description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
#   type        = number
#   default     = 50
# }

# variable "central_node_pool_mode" {
#   description = "(Optional) Should this Node Pool be used for System or User resources? Possible values are System and User. Defaults to User."
#   type        = string
#   default     = "User"
# }

# variable "central_node_pool_node_labels" {
#   description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
#   type        = map(any)
#   default     = {}
# }

# variable "central_node_pool_node_taints" {
#   description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
#   type        = list(string)
#   default     = ["CriticalAddonsOnly=true:NoSchedule"]
# }

# variable "central_node_pool_os_disk_type" {
#   description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
#   type        = string
#   default     = "Ephemeral"
# }

# variable "central_node_pool_os_type" {
#   description = "(Optional) The Operating System which should be used for this Node Pool. Changing this forces a new resource to be created. Possible values are Linux and Windows. Defaults to Linux."
#   type        = string
#   default     = "Linux"
# }

# variable "central_node_pool_priority" {
#   description = "(Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
#   type        = string
#   default     = "Regular"
# }

# variable "central_node_pool_max_count" {
#   description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
#   type        = number
#   default     = 10
# }

# variable "central_node_pool_min_count" {
#   description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
#   type        = number
#   default     = 3
# }

# variable "central_node_pool_node_count" {
#   description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
#   type        = number
#   default     = 3
# }

# variable "central_node_pool_subnet_name" {
#   description = "Specifies the name of the subnet that hosts the default node pool"
#   default     = "UserSubnet"
#   type        = string
# }

# variable "central_node_pool_subnet_address_prefix" {
#   description = "Specifies the address prefix of the subnet that hosts the central node pool"
#   type        = list(string)
#   default     = ["10.0.16.0/20"]
# }

# # misc_NODE_POOL
# variable "misc_node_pool_name" {
#   description = "(Required) Specifies the name of the node pool."
#   type        = string
# }

# variable "misc_node_pool_vm_size" {
#   description = "(Required) The SKU which should be used for the Virtual Machines used in this Node Pool. Changing this forces a new resource to be created."
#   type        = string
#   default     = "Standard_F8s_v2"
# }

# variable "misc_node_pool_availability_zones" {
#   description = "(Optional) A list of Availability Zones where the Nodes in this Node Pool should be created in. Changing this forces a new resource to be created."
#   type        = list(string)
#   default     = ["1", "2", "3"]
# }

# variable "misc_node_pool_enable_auto_scaling" {
#   description = "(Optional) Whether to enable auto-scaler. Defaults to false."
#   type        = bool
#   default     = true
# }

# variable "misc_node_pool_enable_host_encryption" {
#   description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
#   type        = bool
#   default     = false
# }

# variable "misc_node_pool_enable_node_public_ip" {
#   description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
#   type        = bool
#   default     = false
# }

# variable "misc_node_pool_max_pods" {
#   description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
#   type        = number
#   default     = 50
# }

# variable "misc_node_pool_mode" {
#   description = "(Optional) Should this Node Pool be used for System or User resources? Possible values are System and User. Defaults to User."
#   type        = string
#   default     = "User"
# }

# variable "misc_node_pool_node_labels" {
#   description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
#   type        = map(any)
#   default     = {}
# }

# variable "misc_node_pool_node_taints" {
#   description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
#   type        = list(string)
#   default     = ["CriticalAddonsOnly=true:NoSchedule"]
# }

# variable "misc_node_pool_os_disk_type" {
#   description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
#   type        = string
#   default     = "Ephemeral"
# }

# variable "misc_node_pool_os_type" {
#   description = "(Optional) The Operating System which should be used for this Node Pool. Changing this forces a new resource to be created. Possible values are Linux and Windows. Defaults to Linux."
#   type        = string
#   default     = "Linux"
# }

# variable "misc_node_pool_priority" {
#   description = "(Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
#   type        = string
#   default     = "Regular"
# }

# variable "misc_node_pool_max_count" {
#   description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
#   type        = number
#   default     = 10
# }

# variable "misc_node_pool_min_count" {
#   description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
#   type        = number
#   default     = 3
# }

# variable "misc_node_pool_node_count" {
#   description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
#   type        = number
#   default     = 3
# }

# variable "misc_node_pool_subnet_name" {
#   description = "Specifies the name of the subnet that hosts the default node pool"
#   default     = "UserSubnet"
#   type        = string
# }

# variable "misc_node_pool_subnet_address_prefix" {
#   description = "Specifies the address prefix of the subnet that hosts the misc node pool"
#   type        = list(string)
#   default     = ["10.0.16.0/20"]
# }

# ### K8S
# # k8stools_NODE_POOL
# variable "k8stools_node_pool_name" {
#   description = "(Required) Specifies the name of the node pool."
#   type        = string
# }

# variable "k8stools_node_pool_vm_size" {
#   description = "(Required) The SKU which should be used for the Virtual Machines used in this Node Pool. Changing this forces a new resource to be created."
#   type        = string
#   default     = "Standard_F8s_v2"
# }

# variable "k8stools_node_pool_availability_zones" {
#   description = "(Optional) A list of Availability Zones where the Nodes in this Node Pool should be created in. Changing this forces a new resource to be created."
#   type        = list(string)
#   default     = ["1", "2", "3"]
# }

# variable "k8stools_node_pool_enable_auto_scaling" {
#   description = "(Optional) Whether to enable auto-scaler. Defaults to false."
#   type        = bool
#   default     = true
# }

# variable "k8stools_node_pool_enable_host_encryption" {
#   description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
#   type        = bool
#   default     = false
# }

# variable "k8stools_node_pool_enable_node_public_ip" {
#   description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
#   type        = bool
#   default     = false
# }

# variable "k8stools_node_pool_max_pods" {
#   description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
#   type        = number
#   default     = 50
# }

# variable "k8stools_node_pool_mode" {
#   description = "(Optional) Should this Node Pool be used for System or User resources? Possible values are System and User. Defaults to User."
#   type        = string
#   default     = "User"
# }

# variable "k8stools_node_pool_node_labels" {
#   description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
#   type        = map(any)
#   default     = {}
# }

# variable "k8stools_node_pool_node_taints" {
#   description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
#   type        = list(string)
#   default     = ["CriticalAddonsOnly=true:NoSchedule"]
# }

# variable "k8stools_node_pool_os_disk_type" {
#   description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
#   type        = string
#   default     = "Ephemeral"
# }

# variable "k8stools_node_pool_os_type" {
#   description = "(Optional) The Operating System which should be used for this Node Pool. Changing this forces a new resource to be created. Possible values are Linux and Windows. Defaults to Linux."
#   type        = string
#   default     = "Linux"
# }

# variable "k8stools_node_pool_priority" {
#   description = "(Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
#   type        = string
#   default     = "Regular"
# }

# variable "k8stools_node_pool_max_count" {
#   description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
#   type        = number
#   default     = 10
# }

# variable "k8stools_node_pool_min_count" {
#   description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
#   type        = number
#   default     = 3
# }

# variable "k8stools_node_pool_node_count" {
#   description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
#   type        = number
#   default     = 3
# }

# variable "k8stools_node_pool_subnet_name" {
#   description = "Specifies the name of the subnet that hosts the default node pool"
#   default     = "UserSubnet"
#   type        = string
# }

# variable "k8stools_node_pool_subnet_address_prefix" {
#   description = "Specifies the address prefix of the subnet that hosts the misc node pool"
#   type        = list(string)
#   default     = ["10.0.16.0/20"]
# }


# # API VM
# variable "vm_name" {
#   description = "Specifies the name of the jumpbox virtual machine"
#   default     = "TestVm"
#   type        = string
# }

# variable "domain_name_label" {
#   description = "Specifies the domain name for the jumbox virtual machine"
#   default     = "Novotestvm"
#   type        = string
# }


# variable "vm_public_ip" {
#   description = "(Optional) Specifies whether create a public IP for the virtual machine"
#   type        = bool
#   default     = false
# }

# variable "vm_private_ip_address" {
#   type = string
# }

# variable "vm_size" {
#   description = "Specifies the size of the jumpbox virtual machine"
#   default     = "Standard_DS1_v2"
#   type        = string
# }

# variable "vm_os_disk_storage_account_type" {
#   description = "Specifies the storage account type of the os disk of the jumpbox virtual machine"
#   default     = "Premium_LRS"
#   type        = string

#   validation {
#     condition     = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Standard_LRS"], var.vm_os_disk_storage_account_type)
#     error_message = "The storage account type of the OS disk is invalid."
#   }
# }

# variable "vm_os_disk_image" {
#   type        = map(string)
#   description = "Specifies the os disk image of the virtual machine"
#   default = {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-focal"
#     sku       = "20_04-lts"
#     version   = "latest"
#   }
# }
# variable "admin_username" {
#   description = "(Required) Specifies the admin username of the jumpbox virtual machine and AKS worker nodes."
#   type        = string
#   default     = "azadmin"
# }

# variable "ssh_public_key" {
#   description = "(Required) Specifies the SSH public key for the jumpbox virtual machine and AKS worker nodes."
#   type        = string
# }

# variable "script_storage_account_name" {
#   description = "(Required) Specifies the name of the storage account that contains the custom script."
#   type        = string
# }

# variable "script_storage_account_key" {
#   description = "(Required) Specifies the name of the storage account that contains the custom script."
#   type        = string
# }

# variable "container_name" {
#   description = "(Required) Specifies the name of the container that contains the custom script."
#   type        = string
#   default     = "scripts"
# }

# variable "script_name" {
#   description = "(Required) Specifies the name of the custom script."
#   type        = string
#   default     = "configure-jumpbox-vm.sh"
# }

# variable "inline_base64_script"  {
#   description = "(optional) Specifiecs inline base64 encoded script"
#   type = string
#   default = "" 
# }


