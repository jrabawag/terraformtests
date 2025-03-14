variable "subnet_ids" {
  description = "(Required) Specifies the subnets for the Network ACL"
  type        = list(string)
}

variable "public_network_access_enabled" {
  description = "(Optional) Whether public network access is allowed for this Key Vault. Defaults to false."
  type        = bool
  default     = false
}

variable "keyvault_name" {
  description = "(Required) Name of the Central Key Vault"
  type        = string
}
variable "keyvault_resource_group_name" {
  description = "(Required) Resource Group Name of the Central Key Vault"
  type        = string
}
variable "name" {
  description = "(Required) Name of the OpenAI Resource"
  type        = string
}
variable "location" {
  description = "(Required) Location of the OpenAI Resource"
  type        = string
}
variable "resource_group_name" {
  description = "(Required) Resource Group of the OpenAI Resource"
  type        = string
}
variable "netacl_ip_rules" {
  description = "(Required) Specifies the ip CIDR(s) for the Network ACL"
  type        = list(string)
}
# variable "keyvault_endpoint_name" {
#   description = "(Required) Name of the KeyVault entry for endpoint"
#   type        = string
# }

# variable "keyvault_key1_name" {
#   description = "Name of the KeyVault entry for key1"
#   type        = string
#   default     = "key1"
# }

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(any)
  default     = {}
}

variable "log_analytics_workspace_enable" {
  type    = bool
  default = true
}

variable "log_analytics_workspace_id" {
  description = "Specifies the log analytics workspace id"
  type        = string
  default     = "log-NovoDefaultWS-ID"
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
