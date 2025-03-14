variable "name" {
  description = "(Required) Specifies the name of the Container Registry. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Container Registry. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "admin_enabled" {
  description = "(Optional) Specifies whether the admin user is enabled. Defaults to false."
  type        = string
  default     = false
}

variable "sku" {
  description = "(Optional) The SKU name of the container registry. Possible values are Basic, Standard and Premium. Defaults to Basic"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "The container registry sku is invalid."
  }
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(any)
  default     = {}
}

variable "georeplication_locations" {
  description = "(Optional) A list of Azure locations where the container registry should be geo-replicated."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "Specifies the log analytics workspace id"
  type        = string
}

variable "public_network_access_enabled" {
  description = "(Optional) Whether public network access is allowed for the container registry. Defaults to false."
  default     = false
  type        = bool
}

variable "zone_redundancy_enabled" {
  description = "(Optional) Whether zone redundancy is enabled for this Container Registry? Changing this forces a new resource to be created. Defaults to false."
  default     = false
  type        = bool

}

variable "network_rule_set" {
  description = "(Optional) Network rule set object for the container registry"
  type = object({
    default_action = optional(string),
    ip_rule        = optional(list(any))
  })
  default = {}
}

variable "private_endpoint" {
  type = object({
    enable                = bool
    private_dns_zone_id   = string
    private_dns_zone_name = string
    vnet_name             = string
    vnet_rg               = string
    subnet_id             = string
  })
}
