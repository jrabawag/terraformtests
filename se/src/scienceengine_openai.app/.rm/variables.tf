variable "openai_resource" {
  description = "Map of aml ml project configuration."
  type        = map(any)

  default = {}
}

variable "vnet_name" {
  description = "(Required) Name of Virtual Network"
  type        = string
}

variable "vnet_rg" {
  description = "(Required) Resource Group Name of Network Vnet"
  type        = string
}

variable "allowed_ip" {
  description = "(Required) Specifies the ip CIDR(s) for the Network ACL"
  type        = list(string)
}
variable "log_ws_name" {
  description = "(Required) Resource Group of the OpenAI Resource"
  type        = string
}

variable "keyvault_name" {
  description = "KV of the OpenAI Resource"
  type        = string
}

variable "firewall_pip_name" {
  description = "(Required) Specifies the name of the firewall"
  type        = string
}
variable "allow_subnets" {
  description = "(Required) Specifies the ip CIDR(s) for the Network ACL"
  type        = list(string)
}

variable "model_deployment" {
  type = list(object({
    deployment_id   = string
    model_name      = string
    model_format    = string
    model_version   = string
    scale_type      = string
    scale_tier      = optional(string)
    scale_size      = optional(number)
    scale_family    = optional(string)
    scale_capacity  = optional(number)
    rai_policy_name = optional(string)
  }))
  default  = []
  nullable = false
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

variable "appreg_id" {
  type = string
}

variable "location" {
  description = "Specifies the location of the resource"
  type        = string
}


variable "rg" {
  description = "Resource groups"
  type        = map(string)
  default = {
    se        = "rg-scienceengine-weu-se"
    se_deploy = "rg-scienceengine-weu-se-deploy"
  }
}

variable "dns_zones" {
  type = map(string)
}