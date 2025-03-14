variable "name" {
  description = "(Required) Specifies the name of the application insights"
  type        = string
}

variable "location" {
  description = "(Required) Specifies the location of the application insights"
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Specifies the resource group name"
  type        = string
}

variable "workspace_id" {
  description = "(Required) Specifies the log analytices workspace id"
  type        = string
}

variable "tags" {
  description = "(Optional) Specifies the tags of the application insights"
  type        = map(any)
  default     = {}
}