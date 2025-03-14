variable "kv_id" {
  description = "The ID of the Key Vault"
  type        = string
}

variable "secrets" {
  description = "A map of secrets to be stored in Key Vault"
  type = map(object({
    name  = string
    value = string
  }))
}
