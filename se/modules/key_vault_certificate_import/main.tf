# # resource "azurerm_key_vault_certificate" "kvcert" {
# #   for_each     = var.certificates
# #   name         = each.value.name
# #   key_vault_id = var.kv_id
# #   certificate {
# #     contents = each.value.file_path
# #     password = each.value.password
# #   }
# #   lifecycle {
# #     ignore_changes = var.upload_cert ? [] : [certificate]
# #   }
# #   #  lifecycle {
# #   #   # prevent_destroy = true  
# #   #   ignore_changes = var.upload_cert == false ? [certificate] : []
# #   #   # ignore_changes = var.upload_cert == false ? [certificate[0].contents, certificate[0].password] : []
# #   # }
# # }


# resource "azurerm_key_vault_certificate" "kvcert" {
#   for_each    = var.certificates
#   name        = each.value.name
#   key_vault_id = var.kv_id

#   certificate {
#     contents = each.value.file_path
#     password = each.value.password
#   }

#     lifecycle {
#     ignore_changes = [certificate[0].contents, certificate[0].password]
#   }
# }

# # resource "azurerm_key_vault_certificate" "kvcert_with_ignore_changes" {
# #   count       = var.upload_cert == false ? length(var.certificates) : 0
# #   name        = var.certificates[count.index].name
# #   key_vault_id = var.kv_id

# #   certificate {
# #     contents = var.certificates[count.index].file_path
# #     password = var.certificates[count.index].password
# #   }

# #   lifecycle {
# #     ignore_changes = [certificate]
# #     prevent_destroy = true
# #   }
# # }

# # resource "azurerm_key_vault_certificate" "kvcert_without_ignore_changes" {
# #   count       = var.upload_cert == true ? length(var.certificates) : 0
# #   name        = var.certificates[count.index].name
# #   key_vault_id = var.kv_id

# #   certificate {
# #     contents = var.certificates[count.index].file_path
# #     password = var.certificates[count.index].password
# #   }

# #   lifecycle {
# #     ignore_changes = []
# #   }
# # }


# # resource "azurerm_key_vault_certificate" "kvcert" {
# #   name         = var.name
# #   key_vault_id = var.kv_id
# #   certificate {
# #     contents = var.file_path
# #     password =var.password
# #   }
# # }

# locals {
#   existing_certificates = try({
#     for key, cert in var.certificates : 
#     key => data.azurerm_key_vault_certificate.existing[key].id 
#     if can(data.azurerm_key_vault_certificate.existing[key].id)
#   }, {})
# }

# data "azurerm_key_vault_certificate" "existing" {
#   for_each = var.upload_cert ? {} : var.certificates
#   name         = each.value.name
#   key_vault_id = var.kv_id
# }

resource "azurerm_key_vault_certificate" "kvcert" {
  for_each = var.certificates

  name         = each.value.name
  key_vault_id = var.kv_id

  certificate {
    contents = filebase64(each.value.file_path)
    password = each.value.password
  }
  lifecycle {
    ignore_changes = [ certificate[0].contents ]
  }
}
