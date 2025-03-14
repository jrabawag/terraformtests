variable "kv_id" {
  description = "The ID of the Key Vault"
  type        = string
}

variable "certificates" {
  description = "Map of certificates to import"
  type = map(object({
    name        = string
    file_path   = string
    password    = optional(string)
    sensitive   = optional(bool, false)
  }))
  default = {}
}

# variable "upload_cert" {
#   description = "Flag to determine whether to upload certificates"
#   type        = bool
#   default     = false
# }


# variable "name" {
#   type = string
# }

# variable "file_path" {
#   type = string
# }

# variable "password" {
#   type = string
# }