variable "adoPAT" {
  description = "ADO PAT provided in Variable Groups"
  type        = string
}
variable "ADOurl" {
  description = "ADO url"
  type        = string
}
variable "ADOpool" {
  description = "ADO pool"
  type        = string
}
variable "ADOagent" {
  description = "ADO agent"
  type        = string
}

# variable "REDcanvasCert" {
#   description = "The base64-encoded certificate."
#   type        = string
# }

# variable "REDcanvas_PrivKey" {
#   description = "The base64-encoded private key."
#   type        = string
# }




# variable "netacl_ip_rules" {
#   description = "(Required) Specifies the ip CIDR(s) for the Network ACL"
#   type        = list(string)
# }
# variable "adoProject" {
#   description = "ADO Project to pull Variable Groups"
#   type        = string
#   default     = "REDcanvas"
# }


# # variable "Service_Fabric_Window_Admin_Password" {
# #   description = "Service_Fabric_Window_Admin-Password"
# # }

# variable "resource_group_name" {
#   description = "(Required) resource group configuration"
#   type        = string
# }



# # variable "azurerm_resource_group_name" {
# #   description = "(Required) Specifies resource group (azurerm remote backend)"
# #   type        = string
# # }

# # variable "azurerm_storage_account_name" {
# #   description = "(Required) Specifies storage account name (azurerm remote backend)"
# #   type        = string
# # }

# # variable "azurerm_container_name" {
# #   description = "(Required) Specifies BLOB container name (azurerm remote backend)"
# #   type        = string
# #   default     = "tfstate"
# # }

# # variable "azurerm_key" {
# #   description = "(Required) Specifies tfstate file name (azurerm remote backend)"
# #   type        = string
# # }


# #
# # Log Analytics Workspace
# # 



# variable "log_analytics_workspace_rg" {
#   description = "(Required) Resource Group for the Log Analytics Workspace"
#   default     = ""
#   type        = string
# }

# #
# # KeyVault
# #

# variable "kv_name" {
#   description = "(Required) Specifies the name of the key vault."
#   type        = string
# }

# variable "kv_resource_group" {
#   description = "(Required) Specifies resource group"
#   type        = string
# }

# variable "kv_public_network_access_enabled" {
#   description = "(Optional) Whether public network access is allowed for this Key Vault. Defaults to false."
#   type        = bool
#   default     = false
# }

# variable "kv_groups" {
#   description = "(Required) Groups configuration"
#   type = list(object({
#     name                    = string
#     object_id               = string
#     certificate_permissions = list(string)
#     key_permissions         = list(string)
#     secret_permissions      = list(string)
#     storage_permissions     = list(string)
#   }))
# }

# # Storage Account
# variable "sa_name" {
#   description = "(Required) Specifies the name of the Storage Account"
#   type        = string
# }
# variable "sa_account_tier" {
#   description = "(Required) Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
#   type        = string
# }
# variable "sa_replication_type" {
#   description = "(Required) Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
#   type        = string
# }
# variable "sa_disable_firewall" {
#   description = "Defines the use of firewall settings - if set to true to will disable firewall rules. If set to false, firewall will follow the ip_rules and subnets whitelisting"
#   type        = bool
#   default     = "false"
# }
# # variable "devops_objectID" {
# #   description = "(Required) Defines the object ID of the DevOps app reg"
# #   type        = string
# # }

# variable "sa_rbac" {
#   type = list(object({
#     name      = string
#     object_id = string
#   }))
#   default = []
# }

# #
# # Application Insights
# #



# #
# # VNet Data
# #

# variable "vnet_resource_group_name" {
#   description = "(Required) Specifies the rg of vnet"
#   type        = string
# }

# variable "vnet_name" {
#   description = "(Required) Specifies the vnet_name of network rg"
#   type        = string
# }

# variable "firewall_pip_name" {
#   description = "(Required) Specifies the firewall_name of network rg"
#   type        = string
# }

# # variable "ip_rules" { 
# #   description = "(Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault."
# #   default     = []
# # }

# variable "kv_subnet_names" {
#   default = []
# }
# variable "sa_subnet_names" {
#   default = []
# }





# variable "vm_name" {
#   description = "The name of the Virtual Machine"
#   type        = string
# }

# variable "vm_user_name" {
#   description = "The admin username for the Virtual Machine"
#   type        = string
# }

# variable "vm_storage_account_type" {
#   description = "The storage account type for the Virtual Machine OS disk"
#   type        = string
#   default     = "Standard_LRS"
# }

# variable "vm_size" {
#   description = "The size of the Virtual Machine"
#   type        = string
#   default     = "Standard_F2"
# }

# variable "vm_subnet" {
#   description = "The subnet for the ADO Virtual Machine"
#   type        = string
# }




########### -----------------
variable "rg" {
  description = "Resource groups"
  type        = map(string)
  default = {
    se        = "rg-scienceengine-weu-se"
    se_deploy = "rg-scienceengine-weu-se-deploy"
  }
}

variable "rg_rbac" {
  description = "List of users with their object IDs and the roles to assign."
  type = list(
    object({
      name      = string
      object_id = string
      role_name = string
    })
  )
}

variable "network_rbac" {
  description = "List of users with their object IDs and the roles to assign."
  type = list(
    object({
      name      = string
      object_id = string
      role_name = string
      scope     = string
    })
  )
}

variable "additional_se_rbac" {
  type = map(object({
    object_id = string
    role_name = list(string)
  }))
}

variable "project" {
  description = "The name of the project"
  type        = string
}

variable "shortproject" {
  description = "The name of the project"
  type        = string
}

variable "location" {
  description = "(Optional) Specifies the location of the resource"
  type        = string
}

variable "environment" {
  description = "The environment in which this configuration is applied"
  type        = string
}

variable "SE_App_Reg_client_secret" {
  description = "Secret for SE App Registration"
}

variable "SE_Client_API_App_Reg_client_secret" {
  description = "Secret for SE Client API App Registration"
}

variable "SE_DevOps_App_Reg_client_secret" {
  description = "Secret for SE DevOps App Registration"
}

variable "upload_cert" {
  description = "Option to import cert"
}

variable "keyvault" {
  description = "Configuration for the Key Vault"
  type = object({
    name                          = string
    resourcegroup                 = string
    sku_name                      = string
    public_network_access_enabled = optional(bool)
    private_endpoint              = optional(bool)
    allow_subnets                 = optional(list(string))
    resource_lock                 = optional(bool)
    purge_protection_enabled      = optional(bool)
    soft_delete_retention_days    = number
    firewall                      = optional(bool)
    rbac = list(object({
      name      = string
      object_id = string
      role      = string
    }))
  })
}

variable "data" {
  description = "Configuration for network and monitoring resources"
  type = object({
    loga_ws_name     = string
    vnet_rg_name     = string
    vnet_name        = string
    pip_fw_name      = string
    pip_aag_name      = string
    appinsights_name = string
    allow_ip         = list(string)
  })
}

variable "storage_account" {
  description = "Configuration for the storage account"
  type = object({
    name             = string
    account_tier     = string
    replication_type = string
    allow_subnets    = list(string)
    is_hns_enabled   = optional(bool)
    account_kind     = optional(string)
    resource_lock    = bool
    firewall         = optional(bool, true)
    rbac = list(object({
      name      = string
      object_id = string
      role      = string
    }))
    containers = map(object({
      container_access_type = string
    }))
  })
}

variable "adovm" {
  description = "Configuration for the ADO VM"
  type = object({
    name                 = string
    user_name            = string
    storage_account_type = string
    size                 = string
    subnet               = string
    image_name           = string
    gallery_name         = string
    gallery_rg           = string
    exec_command         = list(string)
  })
}

variable "dns_zones" {
  type = map(string)
}