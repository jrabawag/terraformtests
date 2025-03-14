# Input Variables
variable "pip_name" {
  type        = string
  description = "Name of the public IP."
}

variable "location" {
  type        = string
  description = "Location for the resources."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "allocation_method" {
  type        = string
  description = "Allocation method for the public IP."
  default     = "Dynamic"
  validation {
    condition     = contains(["Static", "Dynamic"], var.allocation_method)
    error_message = "Allocation method must be either 'Static' or 'Dynamic'."
  }
}

variable "sku" {
  type        = string
  description = "SKU for the public IP."
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "SKU must be either 'Basic' or 'Standard'."
  }
}

variable "prefix_length" {
  type        = number
  description = "Prefix length for the public IP prefix."
  default     = 30
}

variable "zones" {
  type        = list(string)
  description = "Availability zones for the public IP."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to resources."
  default     = {}
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "ID of the Log Analytics Workspace."
}