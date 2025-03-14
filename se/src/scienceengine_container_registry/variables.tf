variable "se_project" {
  description = "Map of aml ml project configuration."
  type        = map(any)

  default = {}
}

# variable "resource_group_name" {
#   description = "(Required) resource group configuration"
#   type        = string
# }

variable "allow_ip" {
  description = "(Required) Specifies the Novonordisk ip CIDR(s) for the Network ACL"
  type        = list(string)
}

variable "tags" {
  description = "(Optional) Specifies the tags of the log analytics workspace"
  type        = map(any)
  default     = {}
}

# VNET
variable "vnet_name" {
  description = "(Required) Name of Virtual Network"
  type        = string
}

variable "vnet_rg" {
  description = "(Required) Resource Group Name of Network Vnet"
  type        = string
}

variable "firewall_pip_name" {
  description = "(Required) Specifies the name of the firewall"
  type        = string
}

# Log Analytics Workspace
variable "log_ws_name" {
  description = "(Required) Specifies the name of the Log Analytics Workspace"
  default     = ""
  type        = string
}

variable "log_analytics_workspace_rg" {
  description = "(Required) Resource Group for the Log Analytics Workspace"
  default     = ""
  type        = string
}

variable "sa_name" {
  description = "(Required) Specifies the name of the Storage Account"
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


variable "location" {
  description = "(Optional) Specifies the location of the resource"
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