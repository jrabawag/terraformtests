variable "key_vault_name" {
  description = "(Required) Specifies the name of the key vault."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Specifies the resource group name of the key vault."
  type        = string
}

variable "users" {
  description = "(Required) Groups configuration"
  type = list(object({
    name                    = string
    object_id               = string
    certificate_permissions = list(string)
    key_permissions         = list(string)
    secret_permissions      = list(string)
    storage_permissions     = list(string)
  }))
}

variable "groups" {
  description = "(Required) Groups configuration"
  type = list(object({
    name                    = string
    object_id               = string
    certificate_permissions = list(string)
    key_permissions         = list(string)
    secret_permissions      = list(string)
    storage_permissions     = list(string)
  }))
}