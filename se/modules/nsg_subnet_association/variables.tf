variable "subnet_ids" {
  description = "Map of subnet associations, where each key is the subnet name and the value is an object containing subnet_id and network_security_group_id"
  type = map(object({
    subnet_id                 = string
    network_security_group_id = string
  }))
}
