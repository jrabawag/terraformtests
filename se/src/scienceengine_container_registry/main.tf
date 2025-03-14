module "container_registry" {
  source   = "../../modules/container_registry"
  for_each = var.se_project

  name                          = "acr${var.shortproject}${local.location_code}${each.value.acr_name}${lower(var.environment)}"
  resource_group_name           = local.updated_rg["se"]
  location                      = var.location
  sku                           = each.value.acr_sku
  admin_enabled                 = each.value.acr_admin_enabled
  zone_redundancy_enabled       = each.value.acr_zone_redundancy_enabled
  log_analytics_workspace_id    = data.azurerm_log_analytics_workspace.log_workspace.id
  public_network_access_enabled = each.value.acr_firewall_enabled ? false : true
  private_endpoint = {
    enable                = true
    private_dns_zone_id   = data.azurerm_private_dns_zone.dns_zones["acr"].id
    private_dns_zone_name = data.azurerm_private_dns_zone.dns_zones["acr"].name
    vnet_name             = data.azurerm_virtual_network.vnet.name
    vnet_rg               = data.azurerm_virtual_network.vnet.resource_group_name
    subnet_id             = data.azurerm_subnet.pe_subnet.id
  }
  network_rule_set = each.value.acr_firewall_enabled ? {
    default_action = "Deny"
    ip_rule = concat(
      [{
        action   = "Allow"
        ip_range = "${data.azurerm_public_ip.firewall_public_ip.ip_address}/32"
      }],
      [
        for cidr in var.allow_ip : {
          action   = "Allow"
          ip_range = cidr
        }
      ]
    )
  } : null
  tags = local.default_tags
}

#Resource Lock
# module "lock_resources" {
#   source   = "../../modules/management_lock"
#   for_each = var.se_project

#   name       = "lock-acr${var.shortproject}${local.location_code}${each.value.acr_name}${lower(var.environment)}"
#   scope      = module.container_registry[each.key].id
#   lock_level = "CanNotDelete"
#   notes      = "Management lock for ACR to prevent accidental deletion"
# }

module "sa_rbac" {
  source               = "../../modules/rbac"
  for_each             = var.se_project
  scope                = data.azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = module.container_registry[each.key].principal_id
}
