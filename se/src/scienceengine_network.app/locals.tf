locals {
  location_map = {
    "West Europe"    = "weu"
    "North Europe"   = "neu"
    "East US"        = "eus"
    "West US"        = "wus"
    "UK South"       = "uks"
    "France Central" = "frc"
  }

  location_code = local.location_map[var.location]
  default_tags = {
    "environment" = var.environment
    "project"     = var.project
    "createdby"   = "Terraform"
  }

  updated_rg_names = [
    for rg in var.resource_groups : {
      name     = "${rg.name}-${lower(var.environment)}"
      location = rg.location
    }
  ]

  base_address_space = var.vnet_address_space



  subnet_names = {
    for resource_key, resource_value in var.resource_config :
    resource_key => (
      resource_key == "firewall" || resource_key == "bastion" ? resource_value.subnet_name : "${var.project}${resource_value.subnet_name}Subnet"
    )
  }

  subnet_address_prefixes = {
    "firewall"         = cidrsubnet(var.vnet_address_space, 7, 0)  # 10.X.0.0/26
    "bastion"          = cidrsubnet(var.vnet_address_space, 7, 1)  # 10.X.0.64/26
    "agw"              = cidrsubnet(var.vnet_address_space, 5, 1)  # 10.X.1.0/24
    "sfs"              = cidrsubnet(var.vnet_address_space, 5, 2)  # 10.X.2.0/24
    "sfvss"            = cidrsubnet(var.vnet_address_space, 5, 3)  # 10.X.3.0/24
    "sfc"              = cidrsubnet(var.vnet_address_space, 5, 4)  # 10.X.4.0/24
    "sfr"              = cidrsubnet(var.vnet_address_space, 5, 5)  # 10.X.5.0/24
    "m3"               = cidrsubnet(var.vnet_address_space, 5, 6)  # 10.X.6.0/24
    "gptm"             = cidrsubnet(var.vnet_address_space, 5, 7)  # 10.X.7.0/24
    "aks"              = cidrsubnet(var.vnet_address_space, 5, 8)  # 10.X.8.0/24
    "infra_function"   = cidrsubnet(var.vnet_address_space, 5, 9)  # 10.X.9.0/24
    "private_endpoint" = cidrsubnet(var.vnet_address_space, 5, 10) # 10.X.10.0/24
  }

  nsg_subnet_ids = {
    for subnet_name, subnet_value in local.subnet_names :
    subnet_name => module.network.subnet_ids[subnet_value]
    if subnet_value != "AzureFirewallSubnet" && subnet_value != "AzureBastionSubnet"
  }

  udr_subnet_ids = {
    for subnet_name, subnet_value in local.subnet_names :
    subnet_name => module.network.subnet_ids[subnet_value]
    if subnet_value != "AzureFirewallSubnet" && subnet_value != "AzureBastionSubnet" && subnet_value != local.subnet_names["agw"]
  }

  network_rule_collections = [
    for rule_collection in var.network_rule_collections : {
      name     = rule_collection.name
      priority = rule_collection.priority
      action   = rule_collection.action
      rules = [
        for rule in rule_collection.rules : merge(rule, {
          source_addresses = [var.vnet_address_space]
        })
      ]
    }
  ]

  application_rule_collections = [
    for rule_collection in var.application_rule_collections : {
      name     = rule_collection.name
      priority = rule_collection.priority
      action   = rule_collection.action
      rules = [
        for rule in rule_collection.rules : merge(rule, {
          source_addresses = [var.vnet_address_space]
        })
      ]
    }
  ]


  nsg_subnet_associations = [
    for subnet_name, subnet_id in module.network.subnet_ids : {
      subnet_name            = subnet_name
      subnet_id              = subnet_id
      network_security_group = subnet_name == local.subnet_names["agw"] ? module.network_security_groups["agw"].id : module.network_security_groups["default"].id
    }
    if !(subnet_name == "AzureFirewallSubnet" || subnet_name == "AzureBastionSubnet")
  ]
}
