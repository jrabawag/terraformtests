variable "name" {
  description = "Specifies the firewall name"
  type        = string
}

variable "sku_tier" {
  description = "Specifies the firewall SKU tier"
  default     = "Standard"
  type        = string
}

variable "sku_name" {
  description = "Specifies the firewall SKU name"
  default     = "AZFW_VNet"
  type        = string
}

variable "resource_group_name" {
  description = "Specifies the resource group name"
  type        = string
}

variable "location" {
  description = "Specifies the location where the firewall will be deployed"
  type        = string
}

variable "threat_intel_mode" {
  description = "The operation mode for threat intelligence-based filtering (Off, Alert, Deny). Defaults to Alert."
  default     = "Alert"
  type        = string

  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.threat_intel_mode)
    error_message = "The threat intel mode is invalid."
  }
}

variable "zones" {
  description = "Specifies the availability zones of the Azure Firewall"
  default     = null
  type        = list(string)
}

variable "dns_proxy_enabled" {
  description = "Specifies whether the DNS proxy is enabled on the firewall"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "The subnet ID"
  type        = string
}

variable "tags" {
  description = "Specifies the tags for the firewall"
  default     = {}
  type        = map(string)
}

variable "log_analytics_workspace_id" {
  description = "Specifies the Log Analytics workspace ID"
  type        = string
}

variable "public_ip_address_id" {
  description = "Specifies the public IP address ID"
  type        = string
}

variable "application_rule_collections" {
  description = "List of application rule collections"
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                  = string
      source_addresses      = list(string)
      destination_fqdn_tags = list(string)
      destination_fqdns     = list(string)
      protocols = list(object({
        port = string
        type = string
      }))
    }))
  }))
}

variable "network_rule_collections" {
  description = "List of network rule collections"
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                  = string
      source_addresses      = list(string)
      destination_ports     = list(string)
      destination_fqdns     = list(string)
      destination_addresses = list(string)
      protocols             = list(string)
    }))
  }))
}
