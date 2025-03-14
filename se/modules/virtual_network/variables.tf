variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "location" {
  description = "Location in which to deploy the network"
  type        = string
}

variable "vnet_name" {
  description = "VNET name"
  type        = string
}

variable "create_vnet" {
  description = "Create or source VNET"
  type        = bool
  default     = true
}

variable "address_space" {
  description = "VNET address space"
  type        = list(string)
}

variable "subnets" {
  description = "Subnets configuration"
  type = list(object({
    name                                          = string
    address_prefixes                              = list(string)
    service_endpoints                             = list(string)
    private_endpoint_network_policies             = string
    private_link_service_network_policies_enabled = bool
    service_delegations                           = optional(list(string))
  }))
}

variable "tags" {
  description = "(Optional) Specifies the tags of the storage account"
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Specifies the log analytics workspace id"
  type        = string
}