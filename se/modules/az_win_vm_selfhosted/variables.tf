variable "resource_group_name" {
  description = "(Required) Specifies the resource group name of the virtual machine"
  type        = string
}

# variable datadisk_size {
#   description = "(Optional) size of a datadisk"
#   type = number
# }

variable "vm_name" {
  description = "(Required) Specifies the name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "(Required) Specifies the size of the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "(Required) Specifies the admin_username of the virutal machine"
  type        = string
}

variable "admin_password" {
  description = "(Required) Specifies the admin_password of the virutal machine"
  type        = string
}

# variable license_type {
#   description = "(Required) Specifies the license_type of the virtual machine"
#   type = string
# }

# variable source_image_id {
#   description = "(Optional) Specifies the source_image_id of the golden image for the virtual machine"
#   type = string
#   default = ""
# }

# variable "source_image_reference" {
#   type        = map(string)
#   description = "Specifies the source_image_reference of the virtual machine"
# }

variable "os_disk_storage_account_type" {
  description = "(Optional) Specifies the storage account type of the os disk of the virtual machine"
  type        = string

  validation {
    condition     = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Standard_LRS"], var.os_disk_storage_account_type)
    error_message = "The storage account type of the OS disk is invalid."
  }
}

# variable "os_disk_size_gb" {
#   description = "(Optional) Specifies the size of the OS disk"
#   default     = 200
#   type        = number
# }

# variable public_ip {
#   description = "(Optional) Specifies whether create a public IP for the virtual machine"
#   type = bool
#   default = false
# }

variable "location" {
  description = "(Required) Specifies the location of the virtual machine"
  type        = string
}

# variable domain_name_label {
#   description = "(Required) Specifies the DNS domain name of the virtual machine"
#   type = string
# }

variable "subnet_id" {
  description = "(Required) Specifies the resource id of the subnet hosting the virtual machine"
  type        = string
}

# variable "boot_diagnostics_storage_account" {
#   description = "(Optional) The Primary/Secondary Endpoint for the Azure Storage Account (general purpose) which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor."
#   default     = null
# }

# variable "azure_monitor_agent_version" {
#   description = "(Optional) The version of the azure monitor agent"
#   default     = null
# }

# variable "tags" {
#   description = "(Optional) Specifies the tags of the storage account"
#   default     = {}
# }

# variable "log_analytics_workspace_id" {
#   description = "Specifies the log analytics workspace id"
#   type        = string
# }

# variable "log_analytics_workspace_key" {
#   description = "Specifies the log analytics workspace key"
#   type        = string
# }

# variable "log_analytics_workspace_resource_id" {
#   description = "Specifies the log analytics workspace resource id"
#   type        = string
# }


# variable "log_analytics_retention_days" {
#   description = "Specifies the number of days of the retention policy"
#   type        = number
#   default     = 7
# }

#variable "script_storage_account_name" {
#  description = "(Required) Specifies the name of the storage account that contains the custom script."
#  type        = string
#}
#
#variable "script_storage_account_key" {
#  description = "(Required) Specifies the name of the storage account that contains the custom script."
#  type        = string
#}
#
#variable "container_name" {
#  description = "(Required) Specifies the name of the container that contains the custom script."
#  type        = string
#}
#
#variable "script_name" {
#  description = "(Required) Specifies the name of the custom script."
#  type        = string
#}