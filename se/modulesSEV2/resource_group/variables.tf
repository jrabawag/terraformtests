variable "resource_groups" {
  description = "A list of resource groups to be created or referenced"
  type = map(object({
    name     = string
    location = string
  }))
  default = {}
}


variable "tags" {
  description = "Common tags for the resources"
  type        = map(string)
  default     = {}
}

variable "create" {
  description = "Flag to create or reference the rg"
  type        = bool
  default     = true
}