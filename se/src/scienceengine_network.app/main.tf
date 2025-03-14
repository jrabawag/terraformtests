# Resource Groups
module "resource_groups" {
  source          = "../../modules/resource_groups"
  resource_groups = local.updated_rg_names
  tags            = local.default_tags
}

#Log Analytics
module "log_analytics_workspace" {
  source              = "../../modules/log_analytics"
  name                = "log-${var.project}-${local.location_code}-${var.log_analytics_workspace_name}-${lower(var.environment)}"
  resource_group_name = "${var.log_analytics_workspace_rg}-${lower(var.environment)}"
  location            = var.location
  solution_plan_map   = var.solution_plan_map
  tags                = local.default_tags
  depends_on          = [module.resource_groups]
}

#NETWORK
module "network" {
  source                     = "../../modules/virtual_network"
  resource_group_name        = data.azurerm_resource_group.network.name
  location                   = var.location
  vnet_name                  = "${var.vnet_name}-${lower(var.environment)}"
  create_vnet                = false
  address_space              = [var.vnet_address_space]
  log_analytics_workspace_id = module.log_analytics_workspace.id
  tags                       = local.default_tags

  subnets = flatten([
    for resource_key, config in var.resource_config :
    (
      contains(keys(local.subnet_address_prefixes), resource_key) ? [
        {
          name                                          = local.subnet_names[resource_key]
          address_prefixes                              = [local.subnet_address_prefixes[resource_key]]
          service_endpoints                             = config.service_endpoints
          private_endpoint_network_policies             = lookup(config, "private_endpoint_network_policies", "Enabled")
          private_link_service_network_policies_enabled = lookup(config, "private_link_service_network_policies_enabled", false)
          service_delegations                           = config.subnet_delegations
        }
      ] : []
    )
  ])

  depends_on = [module.log_analytics_workspace, module.resource_groups]
}

# #Public IP
module "public_ip" {
  source                     = "../../modules/public_ip"
  for_each = var.public_ip
  pip_name                   = "pip-${var.project}-${local.location_code}-${each.key}-${lower(var.environment)}"
  resource_group_name        = data.azurerm_resource_group.network.name
  location                   = var.location
  tags                       = local.default_tags
  allocation_method          = each.value.allocation_method
  zones                      = each.value.zones
  log_analytics_workspace_id = module.log_analytics_workspace.id
  depends_on                 = [module.network]
}

#Firewall
module "firewall" {
  source                       = "../../modules/firewall"
  name                         = "afw-${var.project}-${local.location_code}-${var.resource_config["firewall"].name}-${lower(var.environment)}"
  location                     = var.location
  resource_group_name          = data.azurerm_resource_group.network.name
  tags                         = local.default_tags
  subnet_id                    = module.network.subnet_ids[var.resource_config["firewall"].subnet_name]
  threat_intel_mode            = "Alert"
  sku_tier                     = var.resource_config["firewall"].sku_tier
  sku_name                     = var.resource_config["firewall"].sku_name
  public_ip_address_id         = module.public_ip["afw"].id
  log_analytics_workspace_id   = module.log_analytics_workspace.id
  dns_proxy_enabled            = true
  application_rule_collections = local.application_rule_collections
  network_rule_collections     = local.network_rule_collections
  depends_on                   = [module.log_analytics_workspace, module.public_ip, module.network]
}

#Route Table
module "route" {
  source              = "../../modules/route_table"
  route_table_name    = lower("se-udr-internetegress-${var.environment}")
  route_name          = "DefaultInternetEgress"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.network.name
  tags                = local.default_tags
  firewall_private_ip = module.firewall.firewall_private_ip
  subnets_to_associate = merge(
    local.udr_subnet_ids,
    {
      "ADOSelfhostedsn" = data.azurerm_subnet.ADOSelfhostedsn.id
    }
  )
  depends_on = [module.firewall, module.network]
}

#Bastion
module "bastion_host" {
  source                     = "../../modules/bastion_host"
  name                       = "bas-${var.project}-${local.location_code}-${var.resource_config["bastion"].host_name}-${lower(var.environment)}"
  resource_group_name        = data.azurerm_resource_group.network.name
  location                   = var.location
  log_analytics_workspace_id = module.log_analytics_workspace.id
  tags                       = local.default_tags
  subnet_id                  = module.network.subnet_ids[var.resource_config["bastion"].subnet_name]
  sku                        = var.bastion_host_sku
  depends_on                 = [module.log_analytics_workspace, module.network]
}

#NSG's
module "network_security_groups" {
  source   = "../../modules/network_security_group"
  for_each = var.network_nsg_rules

  name = "nsg-${var.project}-${local.location_code}-${each.key}-${lower(var.environment)}"

  resource_group_name        = data.azurerm_resource_group.network.name
  log_analytics_workspace_id = module.log_analytics_workspace.id
  location                   = var.location
  security_rules             = each.key == "agw" ? var.network_nsg_rules["agw"] : var.network_nsg_rules["default"]
  tags                       = local.default_tags
  depends_on                 = [module.network]
}

#NSG Association
module "nsg_association" {
  source = "../../modules/nsg_subnet_association"
  subnet_ids = {
    for assoc in local.nsg_subnet_associations :
    assoc.subnet_name => {
      subnet_id                 = assoc.subnet_id
      network_security_group_id = assoc.network_security_group
    }
  }
  depends_on = [module.network, module.network_security_groups]
}

#Private DNS
module "private_dns_zones" {
  source              = "../../modules/private_dns_zone"
  for_each            = var.dns_zones
  name                = each.value
  resource_group_name = data.azurerm_resource_group.network.name
}