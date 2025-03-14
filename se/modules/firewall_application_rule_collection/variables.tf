variable "name" {
  description = "The name of the rule collection group."
  type        = string
}

variable "firewall_policy_id" {
  description = "The ID of the firewall policy."
  type        = string
}

variable "priority" {
  description = "The priority of the rule collection group."
  type        = number
}

variable "application_rule_collections" {
  description = "A list of application rule collections."
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                  = string
      source_addresses      = list(string)
      destination_fqdn_tags = list(string)
      destination_fqdns     = list(string)

      protocols = list(object({
        port = string
        type = string
      }))
    }))
  }))
}
