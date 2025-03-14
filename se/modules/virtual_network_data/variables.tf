variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "vnet_name" {
  description = "VNET name"
  type        = string
}

variable "subnets" {
  description = "Subnets configuration"
  type = list(object({
    name = string
  }))
}


