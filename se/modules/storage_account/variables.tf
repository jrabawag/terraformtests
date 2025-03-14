# General Variables
variable "name" {
  description = "The name of the storage account."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the storage account will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where the storage account will be created."
  type        = string
}

# Storage Account Properties
variable "account_kind" {
  description = "The kind of storage account."
  type        = string
  default     = "StorageV2"
}

variable "account_tier" {
  description = "The performance tier for the storage account (Standard or Premium)."
  type        = string
}

variable "replication_type" {
  description = "The replication strategy for the storage account (e.g., LRS, GRS)."
  type        = string
}

variable "is_hns_enabled" {
  description = "Specifies if the storage account should have Hierarchical Namespace enabled."
  type        = bool
  default     = false
}

variable "enable_https_traffic_only" {
  description = "Specifies whether to allow only HTTPS traffic to storage account."
  type        = bool
  default     = true
}

variable "allow_nested_items_to_be_public" {
  description = "Specifies if nested items in storage can be made public."
  type        = bool
  default     = false
}

variable "infrastructure_encryption_enabled" {
  description = "Enable infrastructure encryption for the storage account."
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Specifies if shared access keys should be enabled."
  type        = bool
  default     = true
}

# Tags
variable "tags" {
  description = "Tags to associate with the resources."
  type        = map(string)
  default     = {}
}

# Network Rules
variable "ip_rules" {
  description = "A list of IP rules for the storage account."
  type        = list(string)
  default     = []
}

variable "virtual_network_subnet_ids" {
  description = "A list of subnet IDs for the storage account."
  type        = list(string)
  default     = []
}

variable "default_action" {
  description = "The default action for network access (Allow or Deny)."
  type        = string
  default     = "Allow"
}

variable "bypass" {
  description = "A list of services to bypass network rules (e.g., AzureServices)."
  type        = list(string)
  default     = ["AzureServices"]
}

# Log Analytics Workspace
variable "log_analytics_workspace_enable" {
  description = "Specifies if diagnostics should be sent to a Log Analytics workspace."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for diagnostic settings."
  type        = string
  default     = null
}

variable "log_analytics_retention_days" {
  description = "The retention period (in days) for diagnostic logs."
  type        = number
  default     = 30
}

# Diagnostic Settings
variable "enable_diagnostic_metrics" {
  description = "Enable metrics in diagnostic settings."
  type        = bool
  default     = true
}

variable "enable_diagnostic_logs" {
  description = "Enable logs in diagnostic settings."
  type        = bool
  default     = true
}

variable "containers" {
  description = "Map of container names with access type"
  type = map(object({
    container_access_type = string
  }))
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
