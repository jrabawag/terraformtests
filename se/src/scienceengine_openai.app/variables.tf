variable "aad_tenant_id" {
  description = "active directory tenant id"
  type        = string
}

variable "environment" {
  description = "The environment in which this configuration is applied"
  type        = string
}

variable "project" {
  description = "The name of the project"
  type        = string
}

variable "shortproject" {
  description = "The short name of the project"
  type        = string
}

variable "devops_sp_id" {
  type = string
}

variable "default_region" {
  type    = string
  default = "weu"
}

variable "location_map" {
  description = "Map of location codes to their respective region names"
  type        = map(string)
  default = {
    weu = "West Europe"
  }
}

variable "acl_allow_ip" {
  description = "(Required) Specifies the ip CIDR(s) for the Network ACL"
  type        = list(string)
}

# DATA
variable "resource_data" {
  type = map(object({
    resource_groups  = optional(list(string), [])
    loga_name        = optional(string, null)
    loga_rg          = optional(string, null)
    kv_name          = optional(string, null)
    kv_rg            = optional(string, null)
    fw_name          = optional(string, null)
    fw_rg            = optional(string, null)
    priv_dns_zones   = optional(list(string), [])
    priv_dns_zone_rg = optional(string, null)
  }))
  # validation {
  #   condition     = contains([for v in var.data : v.read_network], true)
  #   error_message = "At least one use_existing_network must be true."
  # }
}

variable "network_data" {
  description = "Existing Network resources and configuration"
  type = map(object({
    existing      = bool
    vnet_name     = optional(string, "")
    vnet_address = optional(list(string))
    rg_name       = string
    subnets = map(object({
      name                                          = string
      address_prefixes                                        = optional(list(string), null)
      private_endpoint_network_policies             = optional(string, null) #"RouteTableEnabled"
      private_link_service_network_policies_enabled = optional(bool, null)
    }))
  }))
}

variable "deployments" {
  description = "Map of deployment models"
  type = map(object({
    deployment_id   = string
    model_name      = string
    model_format    = string
    model_version   = string
    sku_name        = string
    sku_capacity    = optional(number)
    sku_tier        = optional(string)
    sku_size        = optional(number)
    sku_family      = optional(string)
    rai_policy_name = optional(string)
  }))
}

variable "openai" {
  type = map(object({
    name              = string
    resource_group    = string
    is_private        = bool
    region            = string
    models_deployment = optional(list(string), [])
    fqdns             = optional(list(string), [])
    # public_access_enabled = optional(bool, false)
    outbound_network_access_restricted = optional(bool, false)
  }))
}
