variable "key_vault_id" {
  description = "(Required) Specifies the ID of KeyVault."
  type        = string
}

variable "tenant_id" {
  description = "(Required) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault."
  type        = string
}

variable "groups" {
  description = "(Required) Application configuration"
  type = list(object({
    name                    = string
    object_id               = string
    application_id          = string
    certificate_permissions = list(string)
    key_permissions         = list(string)
    secret_permissions      = list(string)
    storage_permissions     = list(string)
  }))
}
