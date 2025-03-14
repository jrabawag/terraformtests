variable "resource_groups" {
  description = "(Required) resource group configuration"
  type = list(object({
    name     = string
    location = string
  }))
}

variable "tags" {
  description = "(Optional) Specifies the tags of the log analytics workspace"
  type        = map(any)
  default     = {}
}
