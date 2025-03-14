data "azurerm_resource_group" "net_rg" {
  for_each = var.data
  name     = each.value.network_rg
}

data "azurerm_virtual_network" "vnet" {
  for_each            = var.data
  name                = each.value.vnet_name
  resource_group_name = data.azurerm_resource_group.net_rg[each.key].name
  depends_on          = [ data.azurerm_resource_group.net_rg ]
}

data "azurerm_subnet" "pe_subnet" {
  for_each            = var.data
  name                = each.value.subnet_name
  resource_group_name = data.azurerm_resource_group.net_rg[each.key].name
  virtual_network_name= data.azurerm_virtual_network.vnet[each.key].name
  depends_on          = [
    data.azurerm_resource_group.net_rg,
    data.azurerm_virtual_network.vnet
  ]
}

data "azurerm_private_dns_zone" "dns_zone" {
  for_each            = var.data
  name                = each.value.priv_dns_name
  resource_group_name = data.azurerm_resource_group.net_rg[each.key].name
  depends_on          = [ data.azurerm_resource_group.net_rg ]
}