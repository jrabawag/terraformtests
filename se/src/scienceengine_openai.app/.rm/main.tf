module "openai" {
  source   = "../../modules/open_ai"
  for_each = var.openai_resource

  name                           = "openai-${var.shortproject}-${local.location_code}-${each.value.openai_name}-${lower(var.environment)}"
  resource_group_name            = local.updated_rg["se"]
  location                       = var.location
  netacl_ip_rules                = var.allowed_ip
  subnet_ids                     = each.value.firewall_enabled ? values(data.azurerm_subnet.allowed_opai_subnet)[*].id : []
  keyvault_name                  = "${var.keyvault_name}${lower(var.environment)}"
  keyvault_resource_group_name   = local.updated_rg["se"]
  public_network_access_enabled  = each.value.firewall_enabled ? false : true
  log_analytics_workspace_enable = true
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.log_workspace.id
  private_endpoint = {
    enable                = true
    private_dns_zone_id   = data.azurerm_private_dns_zone.dns_zones["openai"].id
    private_dns_zone_name = data.azurerm_private_dns_zone.dns_zones["openai"].name
    vnet_name             = data.azurerm_virtual_network.vnet.name
    vnet_rg               = data.azurerm_virtual_network.vnet.resource_group_name
    subnet_id             = data.azurerm_subnet.pe_subnet.id
  }
  tags = local.default_tags

}
module "model_deployment" {
  source                     = "../../modules/model_deployment"
  for_each                   = module.openai
  openai_resource_group_name = local.updated_rg["se"]
  openai_account_name        = each.value.name
  model_deployment           = var.model_deployment
  depends_on                 = [module.openai]
}

# #Resource Lock
# module "lock_resources" {
#   source   = "../../modules/management_lock"
#   for_each = var.openai_resource

#   name       = "lock-${each.value.openai_name}"
#   scope      = module.openai[each.key].openai_id
#   lock_level = "CanNotDelete"
#   notes      = "Management lock for OpenAi to prevent accidental deletion"
# }

module "sa_rbac" {
  source   = "../../modules/rbac"
  for_each = module.openai

  scope                = each.value.openai_id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = var.appreg_id
}

