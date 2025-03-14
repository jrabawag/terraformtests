variable "name" {
  description = "(Required) The name of the management lock resource."
  type        = string
}

variable "scope" {
  description = "(Required) The scope of the management lock."
  type        = string
}

variable "lock_level" {
  description = "(Required) Specifies the level of the management lock applied to the resource (e.g., 'CanNotDelete', 'ReadOnly')."
  type        = string
}

variable "notes" {
  description = "(Optional) Additional notes or information about the resource."
  type        = string
  default     = null
}
