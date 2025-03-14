data "azurerm_client_config" "current" {
}

data "azurerm_public_ip" "firewall_public_ip" {
  name                = "${var.firewall_pip_name}-${lower(var.environment)}"
  resource_group_name = "${var.vnet_rg}-${lower(var.environment)}"
}
data "azurerm_log_analytics_workspace" "log_workspace" {
  name                = "${var.log_ws_name}-${lower(var.environment)}"
  resource_group_name = local.updated_rg["se_deploy"]
}


data "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}-${lower(var.environment)}"
  resource_group_name = "${var.vnet_rg}-${lower(var.environment)}"
}

# data "azurerm_subnet" "adovm_subnet" {
#   name                 = var.adovm.subnet
#   virtual_network_name = data.azurerm_virtual_network.vnet.name
#   resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
# }


data "azurerm_subnet" "allowed_opai_subnet" {
  for_each             = { for subnet_name in local.dynamic_openai_subnet_names : subnet_name => subnet_name }
  name                 = each.value
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}


data "azurerm_resource_group" "sedeploy_rg" {
  name = local.updated_rg["se_deploy"]
}

data "azurerm_resource_group" "se_rg" {
  name = local.updated_rg["se"]
}


data "azurerm_subnet" "pe_subnet" {
  name                 = "ScienceEnginePrivateEndpointSubnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}


data "azurerm_private_dns_zone" "dns_zones" {
  for_each            = var.dns_zones
  name                = each.value
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
}