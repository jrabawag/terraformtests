variable "vm_name" {
  description = "The name of the virtual machine and associated resources"
  type        = string
}

variable "location" {
  description = "The Azure location where the resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet in which the network interface will be created"
  type        = string
}

variable "username" {
  description = "The username for accessing the virtual machine"
  type        = string
}

variable "password" {
  description = "The password for accessing the virtual machine"
  type        = string
}

variable "storage_account_type" {
  description = "The type of storage account to use for the OS disk"
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
}

variable "tags" {
  description = "(Optional) Specifies the tags of the VM"
  default     = {}
}

variable "source_image_id" {
  type = string
}
# New variables for remote-exec
variable "enable_remote_exec" {
  description = "Flag to enable remote-exec on the VM"
  type        = bool
  default     = false
}

variable "remote_exec_commands" {
  description = "List of commands to execute remotely on the VM"
  type        = list(string)
  default     = []
}