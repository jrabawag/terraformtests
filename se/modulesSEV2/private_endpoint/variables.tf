# variable "name" {
#   description = "(Required) Specifies the name of the private endpoint. Changing this forces a new resource to be created."
#   type        = string
# }

# variable "resource_group_name" {
#   description = "(Required) The name of the resource group. Changing this forces a new resource to be created."
#   type        = string
# }

# variable "private_connection_resource_id" {
#   description = "(Required) Specifies the resource id of the private link service"
#   type        = string 
# }

# variable "location" {
#   description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
#   type        = string
# }

# variable "subnet_id" {
#   description = "(Required) Specifies the resource id of the subnet"
#   type        = string
# }

# variable "is_manual_connection" {
#   description = "(Optional) Specifies whether the private endpoint connection requires manual approval from the remote resource owner."
#   type        = string
#   default     = false  
# }

# variable "subresource_name" {
#   description = "(Optional) Specifies a subresource name which the Private Endpoint is able to connect to."
#   type        = string
#   default     = null
# }

# variable "request_message" {
#   description = "(Optional) Specifies a message passed to the owner of the remote resource when the private endpoint attempts to establish the connection to the remote resource."
#   type        = string
#   default     = null 
# }

# variable "private_dns_zone_group_name" {
#   description = "(Required) Specifies the Name of the Private DNS Zone Group. Changing this forces a new private_dns_zone_group resource to be created."
#   type        = string
# }

# variable "private_dns_zone_group_ids" {
#   description = "(Required) Specifies the list of Private DNS Zones to include within the private_dns_zone_group."
#   type        = list(string)
# }



# variable "private_dns" {
#   default = {}
# }



# variable "private_dns_zone" {
#   type = object({
#     name                = string
#     resource_group_name = optional(string)
#   })
#   default     = null
#   description = "A map of object that represents the existing Private DNS Zone you'd like to use."
# }

# variable "private_endpoint" {
#   type = map(object({
#     name                               = string
#     vnet_rg_name                       = string
#     vnet_name                          = string
#     subnet_name                        = string
#     target_resource_id                 = string
#     location                           = optional(string, null)
#     private_dns_zone                   = string
#     dns_zone_virtual_network_link_name = optional(string, "dns_zone_link")
#     private_dns_entry_enabled          = optional(bool, false)
#     private_service_connection_name    = optional(string, "privateserviceconnection")
#     is_manual_connection               = optional(bool, false)
#     dns_record                         = optional(string, "")
#     subresource                        = optional(string, null)
#     request_message                    = optional(string, null)
#   }))
#   description = "A map of objects that represent the configuration for a private endpoint."
#   nullable    = false
# }


variable "tags" {
  description = "(Optional) Specifies the tags of the network security group"
  default     = {}
}

variable "data" {
  type = map(object({
    network_rg                         = string
    vnet_name                          = string
    subnet_name                        = string
    priv_dns_name                      = string
  }))
  description = "A map of objects that represent the configuration for a private endpoint."
  nullable    = false
}

variable "private_endpoint" {
  type = map(object({
    name                               = string
    vnet_rg_name                       = string
    vnet_name                          = string
    subnet_name                        = string
    location                           = optional(string, null)
    dns_zone_virtual_network_link_name = optional(string, "dns_zone_link")
    private_dns_entry_enabled          = optional(bool, false)
    private_service_connection_name    = optional(string, "privateserviceconnection")
    is_manual_connection               = optional(bool, false)
  }))
  default     = {}
  description = "A map of objects that represent the configuration for a private endpoint."
  nullable    = false
}


variable "name" {
  description = "Name of the private endpoint"
  type        = string
}
variable "target_resource_id" {
  description = "Target resource ID"
  type        = string
}

variable "location" {
  description = "Location of the private endpoint"
  type        = string
  default     = null
}
variable "dns_zone_virtual_network_link_name" {
  description = "DNS zone virtual network link name"
  type        = string
  default     = "dns_zone_link"
}

variable "private_dns_entry_enabled" {
  description = "Enable private DNS entry"
  type        = bool
  default     = false
}

variable "private_service_connection_name" {
  description = "Name of the private service connection"
  type        = string
  default     = "privateserviceconnection"
}

variable "is_manual_connection" {
  description = "Indicates if the connection is manual"
  type        = bool
  default     = false
}

variable "dns_record" {
  description = "DNS record"
  type        = string
  default     = ""
}

variable "subresource" {
  description = "Subresource"
  type        = list(string)
  default     = null
}

variable "request_message" {
  description = "Request message"
  type        = string
  default     = null
}
