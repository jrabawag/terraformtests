resource "azurerm_route_table" "route" {
  name                = var.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  route {
    name                   = var.route_name
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }

  lifecycle {
    ignore_changes = [
      tags,
      route
    ]
  }
}


resource "azurerm_subnet_route_table_association" "subnet_association" {
  for_each = var.subnets_to_associate

  subnet_id      = each.value
  route_table_id = azurerm_route_table.route.id
  depends_on     = [azurerm_route_table.route]
}
