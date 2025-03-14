output "resource_groups" {
  value = merge(
    { for key, rg in azurerm_resource_group.this : key => {
      name     = rg.name
      id       = rg.id
      location = rg.location
    } },
    { for key, rg in data.azurerm_resource_group.this : key => {
      name     = rg.name
      id       = rg.id
      location = rg.location
    } }
  )
}
