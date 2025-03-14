resource "azurerm_key_vault_secret" "secrets" {
  for_each     = var.secrets
  name         = each.value.name
  value        = each.value.value
  key_vault_id = var.kv_id
}
