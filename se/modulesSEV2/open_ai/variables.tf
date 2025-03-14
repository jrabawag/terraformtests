variable "location" {
  type        = string
  description = "Azure OpenAI deployment region. Set this variable to `null` would use resource group's location."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the azure resource group to use. The resource group must exist."
}

variable "account_name" {
  type        = string
  default     = ""
  description = "Specifies the name of the Cognitive Service Account. Changing this forces a new resource to be created. Leave this variable as default would use a default name with random suffix."
}

# variable "application_name" {
#   type        = string
#   default     = ""
#   description = "Name of the application. A corresponding tag would be created on the created resources if `var.default_tags_enabled` is `true`."
# }

variable "custom_subdomain_name" {
  type        = string
  default     = ""
  description = "The subdomain name used for token-based authentication. Changing this forces a new resource to be created. Leave this variable as default would use a default name with random suffix."
}

variable "customer_managed_key" {
  type = object({
    key_vault_key_id   = string
    identity_client_id = optional(string)
  })
  default     = null
  description = "Encryption"
}

variable "deployment" {
  type = map(object({
    deployment_id   = string
    model_name      = string
    model_format    = string
    model_version   = string
    sku_name        = string
    sku_capacity    = optional(number, null)
    sku_tier        = optional(string)
    sku_size        = optional(number)
    sku_family      = optional(string)
    rai_policy_name = optional(string, null)

    version_upgrade_option     = optional(string, "OnceCurrentVersionExpired")
    dynamic_throttling_enabled = optional(bool, false)
  }))
  default     = {}
  description = "The Cognitive Services Account Deployment."
  nullable    = false
}

variable "diagnostic_setting" {
  type = map(object({
    name                           = string
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    eventhub_name                  = optional(string)
    eventhub_authorization_rule_id = optional(string)
    storage_account_id             = optional(string)
    partner_solution_id            = optional(string)
    audit_log_retention_policy = optional(object({
      enabled = optional(bool, true)
    }))
    request_response_log_retention_policy = optional(object({
      enabled = optional(bool, true)
    }))
    trace_log_retention_policy = optional(object({
      enabled = optional(bool, true)
    }))
    metric_retention_policy = optional(object({
      enabled = optional(bool, true)
    }))
  }))
  default     = {}
  description = "A map of objects that represent the configuration for a diagnostic setting."
  nullable    = false
}

variable "dynamic_throttling_enabled" {
  type        = bool
  default     = null
  description = "Determines whether or not dynamic throttling is enabled. If set to `true`, dynamic throttling will be enabled. If set to `false`, dynamic throttling will not be enabled."
}

variable "fqdns" {
  type        = list(string)
  default     = null
  description = "List of FQDNs allowed for the Cognitive Account."
}

variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default     = null
  description = "Specifies the Identity to be assigned to this OpenAI Account."
}

variable "local_auth_enabled" {
  type        = bool
  default     = true
  description = "Whether local authentication methods is enabled for the Cognitive Account. Defaults to `true`."
}

variable "network_acls" {
  type = map(object({
    default_action = optional(string, "Deny")
    ip_rules       = optional(set(string))
    virtual_network_rules = optional(object({
      subnet_id                            = optional(string, null)
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    }))
  }))
  default     = null
  description = "Network access"
}

variable "outbound_network_access_restricted" {
  type        = bool
  default     = false
  description = "Whether outbound network access is restricted for the Cognitive Account. Defaults to `false`."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Whether public network access is allowed for the Cognitive Account. Defaults to `false`."
}

variable "sku_name" {
  type        = string
  default     = "S0"
  description = "Specifies the SKU Name for this Cognitive Service Account. Possible values are `F0`, `F1`, `S0`, `S`, `S1`, `S2`, `S3`, `S4`, `S5`, `S6`, `P0`, `P1`, `P2`, `E0` and `DC0`. Default to `S0`."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) A mapping of tags to assign to the resource."
  nullable    = false
}

# variable "subnet_ids" {
#   description = "(Required) Specifies the subnets for the Network ACL"
#   type        = list(string)
# }

# variable "public_network_access_enabled" {
#   description = "(Optional) Whether public network access is allowed for this Key Vault. Defaults to false."
#   type        = bool
#   default     = false
# }

# variable "keyvault_name" {
#   description = "(Required) Name of the Central Key Vault"
#   type        = string
# }
# variable "keyvault_resource_group_name" {
#   description = "(Required) Resource Group Name of the Central Key Vault"
#   type        = string
# }
# variable "name" {
#   description = "(Required) Name of the OpenAI Resource"
#   type        = string
# }
# variable "location" {
#   description = "(Required) Location of the OpenAI Resource"
#   type        = string
# }
# variable "resource_group_name" {
#   description = "(Required) Resource Group of the OpenAI Resource"
#   type        = string
# }
# variable "netacl_ip_rules" {
#   description = "(Required) Specifies the ip CIDR(s) for the Network ACL"
#   type        = list(string)
# }
# # variable "keyvault_endpoint_name" {
# #   description = "(Required) Name of the KeyVault entry for endpoint"
# #   type        = string
# # }

# # variable "keyvault_key1_name" {
# #   description = "Name of the KeyVault entry for key1"
# #   type        = string
# #   default     = "key1"
# # }

# variable "tags" {
#   description = "(Optional) A mapping of tags to assign to the resource."
#   type        = map(any)
#   default     = {}
# }

# variable "log_analytics_workspace_enable" {
#   type    = bool
#   default = true
# }

# variable "log_analytics_workspace_id" {
#   description = "Specifies the log analytics workspace id"
#   type        = string
#   default     = "log-NovoDefaultWS-ID"
# }

# variable "private_endpoint" {
#   type = object({
#     enable                = bool
#     private_dns_zone_id   = string
#     private_dns_zone_name = string
#     vnet_name             = string
#     vnet_rg               = string
#     subnet_id             = string
#   })
# }

# variable "default_action" {
#   description = "(Required) The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids. Possible values are Allow and Deny."
#   type        = string
#   default     = "Allow"

#   validation {
#     condition     = contains(["Allow", "Deny"], var.default_action)
#     error_message = "The value of the default action property of the key vault is invalid."
#   }
# }