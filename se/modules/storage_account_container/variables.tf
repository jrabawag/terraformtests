variable "storage_account_id" {
  description = "Name of the storage account"
  type        = string
}
variable "container_name" {
  description = "Name of the blob container"
  type        = string
}

variable "container_access_type" {
  description = "Access type for the blob container"
  type        = string
  default     = "private"
}