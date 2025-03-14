data "azurerm_client_config" "current" {
}

#Network RG
data "azurerm_resource_group" "network" {
  name = "${var.network_resource_group_name}-${lower(var.environment)}"
}
#ADO Subnet
data "azurerm_subnet" "ADOSelfhostedsn" {
  name                 = var.azureADO_subnet_name
  virtual_network_name = "${var.vnet_name}-${lower(var.environment)}"
  resource_group_name  = data.azurerm_resource_group.network.name
}
