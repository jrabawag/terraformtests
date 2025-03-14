# 2022-08-12 Thomas S. Iversen <tsiv@nnit.com>
#
# Implemented terraform prerequisites for NN REDcanvas project
# 
# NN Requirements found here: https://novonordiskit.visualstudio.com/GITO-HS/
#
# [Fulfilled]    SR.AZR.KeyVault.vaults.001 - Ensure that logging for Azure KeyVault is 'Enabled'
# [Fulfilled]    SR.AZR.KeyVault.vaults.002 - Ensure that there is no NN Azure user, group or application with full administrator privileges
# [Fulfilled]    SR.AZR.KeyVault.vaults.003 - Ensure that Soft-Delete is enabled

data "azurerm_client_config" "current" {
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "random_string" "key_vault_name_prefix_suffix" {
  length      = 6
  special     = false
  lower       = true
  upper       = false
  numeric     = true
  min_numeric = 3

  keepers = {
    # Generate a new integer each time we switch to a new listener ARN
    name = var.key_vault_name
  }
}

module "key_vault" {
  source                         = "../../modules/key_vault"
  name                           = var.key_vault_name
  location                       = data.azurerm_resource_group.this.location
  resource_group_name            = data.azurerm_resource_group.this.name
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  log_analytics_workspace_enable = false
}

resource "azurerm_key_vault_access_policy" "application" {
  key_vault_id = module.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  certificate_permissions = [
    "Get",
    "List",
    "Update",
    "Create",
    "Import",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "ManageContacts",
    "ManageIssuers",
    "GetIssuers",
    "ListIssuers",
    "SetIssuers",
    "DeleteIssuers",
  ]
  key_permissions = [
    "Get",
    "List",
    "Update",
    "Create",
    "Import",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Decrypt",
    "Encrypt",
    "Verify",
    "Sign",
    "Purge",
  ]
  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge",
  ]
  storage_permissions = [
    "Get",
    "List",
    "Delete",
    "Set",
    "Update",
    "RegenerateKey",
    "SetSAS",
    "ListSAS",
    "GetSAS",
    "DeleteSAS",
  ]

  depends_on = [
    module.key_vault,
  ]
}

module "user_policies" {
  source       = "../../modules/key_vault_group_access"
  key_vault_id = module.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  groups       = var.users

  depends_on = [
    azurerm_key_vault_access_policy.application,
  ]
}

module "group_policies" {
  source       = "../../modules/key_vault_group_access"
  key_vault_id = module.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  groups       = var.groups

  depends_on = [
    azurerm_key_vault_access_policy.application,
  ]
}
