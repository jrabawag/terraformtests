data "azurerm_client_config" "current" {
}

data "azurerm_log_analytics_workspace" "log_workspace" {
  name                = "${var.data.loga_ws_name}-${lower(var.environment)}"
  resource_group_name = local.updated_rg["se_deploy"]
}

data "azurerm_resource_group" "vnet-rg" {
  name                = "${var.data.vnet_rg_name}-${lower(var.environment)}"
}
data "azurerm_virtual_network" "vnet" {
  name                = "${var.data.vnet_name}-${lower(var.environment)}"
  resource_group_name = "${var.data.vnet_rg_name}-${lower(var.environment)}"
}

data "azurerm_public_ip" "firewall_public_ip" {
  name                = "${var.data.pip_fw_name}-${lower(var.environment)}"
  resource_group_name = "${var.data.vnet_rg_name}-${lower(var.environment)}"
}

data "azurerm_public_ip" "aag_public_ip" {
  name                = "${var.data.pip_aag_name}-${lower(var.environment)}"
  resource_group_name = "${var.data.vnet_rg_name}-${lower(var.environment)}"
}

data "azurerm_subnet" "adovm_subnet" {
  name                 = var.adovm.subnet
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_shared_image" "nnwin2019" {
  name                = var.adovm.image_name
  gallery_name        = var.adovm.gallery_name
  resource_group_name = var.adovm.gallery_rg
  provider            = azurerm.gallery
}

data "azurerm_subnet" "allowed_sa_subnet" {
  for_each             = { for subnet_name in local.dynamic_sa_subnet_names : subnet_name => subnet_name }
  name                 = each.value
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_subnet" "allowed_kv_subnet" {
  for_each             = { for subnet_name in local.dynamic_kv_subnet_names : subnet_name => subnet_name }
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

data "azurerm_resource_group" "se_net_rg" {
  name = local.updated_rg["se_network"]
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

# data "azurerm_key_vault_certificate" "existing_certificates" {
#   for_each     = var.upload_cert ? {} : {
#     "TlsCertificate"              = "TlsCertificate"
#     "ClusterCertificate"          = "ClusterCertificate"
#     "CanvasStartup-S2SclientCert" = "CanvasStartup-S2SclientCert"
#   }
#   name         = each.key
#   key_vault_id = module.keyvault.id
# }

