variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region for the resources"
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "create_vnet" {
  description = "Flag to create or reference the virtual network"
  type        = bool
}

# variable "vnet_address" {
#   description = "The address space of the virtual network"
#   type        = list(string)
#   default     = ["10.0.0.0/16"]
# }
variable "vnet_address_space" {
  description = "The address space of the virtual network"
  type        = list(string)
  default     = []
}

variable "create_subnet" {
  description = "Flag to create or reference the subnet"
  type        = bool
  default     = true
}

variable "subnets" {
  description = "Configuration for subnets"
  type = map(object({
    name                                           = string
    address_prefixes                               = optional(list(string), []) # Ensure it defaults to an empty list
    service_endpoints                              = optional(list(string), [])
    private_endpoint_network_policies              = optional(string, "Disabled")
    private_link_service_network_policies_enabled  = optional(bool, false)
    service_delegations                            = optional(list(string), [])
  }))
  default = {}
}


variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
  default     = {}
}


variable "log_analytics_workspace_id" {
  description = "Specifies the log analytics workspace id"
  type        = string
  default     = null
}