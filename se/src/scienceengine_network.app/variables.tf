variable "resource_groups" {
  description = "(Required) resource group configuration"
  type = list(object({
    name     = string
    location = string
  }))
}

variable "network_resource_group_name" {
  description = "Specifies the resource group name of the VNET"
  type        = string
}

variable "location" {
  description = "Specifies the location for the resource group and all the resources"
  default     = "westeurope"
  type        = string
}

variable "tags" {
  description = "(Optional) Specifies tags for all the resources"
  default = {
    createdWith = "Terraform"
  }
}

variable "environment" {
  description = "The environment in which this configuration is applied"
  type        = string
}

variable "project" {
  description = "The name of the project"
  type        = string
}

variable "vnet_address_space" {
  description = "Specifies the address prefix of the Vnet"
  default     = ""
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Specifies the name of the log analytics workspace"
  type        = string
}
variable "log_analytics_workspace_rg" {
  description = "(Required) Resource Group for the Log Analytics Workspace"
  default     = ""
  type        = string
}
variable "solution_plan_map" {
  description = "(Optional) Specifies the map structure containing the list of solutions to be enabled."
  type        = map(any)
  default     = {}
}

variable "vnet_name" {
  description = "Specifies the name of the Vnet"
  default     = "VNet"
  type        = string
}


variable "bastion_host_sku" {
  description = "SKU of bastion resource."
  default     = "Standard"
  type        = string
}

variable "azureADO_subnet_name" {
  description = "Specifies the name of the ADO subnet"
  type        = string
}

variable "resource_config" {
  description = "Map of resource configurations for various subnets"
  type = map(object({
    subnet_name                                   = string
    service_endpoints                             = optional(list(string), [])
    host_name                                     = optional(string)
    private_endpoint_network_policies             = string
    private_link_service_network_policies_enabled = bool
    subnet_delegations                           = optional(list(string), [])
    zones                                         = optional(list(string))
    dns_proxy_enabled                             = optional(bool)
    sku_tier                                      = optional(string)
    sku_name                                      = optional(string)
    name                                          = optional(string)
  }))
}

variable "network_rule_collections" {
  description = "A list of network rule collections."
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                  = string
      destination_ports     = list(string)
      destination_addresses = list(string)
      destination_fqdns     = list(string)
      protocols             = list(string)
    }))
  }))
}

variable "application_rule_collections" {
  description = "A list of application rule collections."
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                  = string
      destination_fqdn_tags = list(string)
      destination_fqdns     = list(string)
      protocols = list(object({
        port = string
        type = string
      }))
    }))
  }))
}

variable "network_nsg_rules" {
  description = "Map of NSG rules for different NSGs"
  type = map(list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  })))
}

variable "dns_zones" {
  type = map(string)
}

variable "public_ip" {
  description = "Configuration for public IPs, including allocation method, prefix length, zones, and SKU."
  type = map(object({
    allocation_method = optional(string, "Dynamic")           
    prefix_length     = optional(number, 30)  
    zones             = optional(list(string), [])
    sku               = optional(string, "Standard")
  }))
}
