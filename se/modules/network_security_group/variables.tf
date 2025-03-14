variable "name" {
  description = "(Required) Specifies the name of the network security group"
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Specifies the resource group name of the network security group"
  type        = string
}

variable "location" {
  description = "(Required) Specifies the location of the network security group"
  type        = string
}

# Original found not to be working with the object approach
# variable "security_rules" {
#   description = "(Optional) Specifies the security rules of the network security group"
#   type        = list(object)
#   default     = []
# }

# Working but require the 'experiments = [module_variable_optional_attrs]' statement in Main
variable "security_rules" {
  description = "(Optional) Specifies the security rules of the network security group"
  type = list(object({
    name                                       = string
    priority                                   = number
    direction                                  = string
    access                                     = string
    protocol                                   = string
    source_port_range                          = string
    source_port_ranges                         = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    source_application_security_group_ids      = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
  }))
  default = []
}

# Working doesn't require the 'experiments = [module_variable_optional_attrs]' statement in Main
# variable "security_rules" {
#   description = "(Optional) Specifies the security rules of the network security group"
#   type        = list(object({
#     name                                        = string
#     priority                                    = number
#     direction                                   = string
#     access                                      = string
#     protocol                                    = string
#     source_port_range                           = string
#     source_port_ranges                          = list(string)
#     destination_port_range                      = string
#     destination_port_ranges                     = list(string)
#     source_address_prefix                       = string
#     source_address_prefixes                     = list(string)
#     destination_address_prefix                  = string
#     destination_address_prefixes                = list(string)
#     source_application_security_group_ids       = list(string)
#     destination_application_security_group_ids  = list(string)
#   }))
#   default     = []
# }

variable "tags" {
  description = "(Optional) Specifies the tags of the network security group"
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Specifies the log analytics workspace resource id"
  type        = string
}
