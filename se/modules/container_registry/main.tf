terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  # experiments = [module_variable_optional_attrs]

  required_version = ">= 0.14.9"
}

locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = merge(var.tags, local.module_tag)
}

resource "azurerm_container_registry" "acr" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  zone_redundancy_enabled       = var.zone_redundancy_enabled
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }
  dynamic "georeplications" {
    for_each = var.georeplication_locations

    content {
      location = georeplications.value
      tags     = var.tags
    }
  }

  network_rule_set {
    default_action = try(var.network_rule_set.default_action, null)
    ip_rule        = try(var.network_rule_set.ip_rule, [])
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  metric {
    category = "AllMetrics"
  }
  depends_on = [azurerm_container_registry.acr]
}

#DATA VNET
data "azurerm_virtual_network" "vnet" {
  name                = var.private_endpoint.vnet_name
  resource_group_name = var.private_endpoint.vnet_rg
}


#Private Endpoint
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  count               = var.private_endpoint.enable ? 1 : 0
  name                = "pe-${var.name}"
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  location            = data.azurerm_virtual_network.vnet.location
  subnet_id           = var.private_endpoint.subnet_id

  private_service_connection {
    name                           = "${var.name}-connection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
  depends_on = [azurerm_container_registry.acr]
}

# Private Endpoint Connection Data
data "azurerm_private_endpoint_connection" "private_ip1" {
  count               = var.private_endpoint.enable ? 1 : 0
  name                = azurerm_private_endpoint.acr_private_endpoint[0].name
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
}

# Conditional Private DNS Zone Link
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
  count                 = var.private_endpoint.enable ? 1 : 0
  name                  = "${azurerm_container_registry.acr.name}-dns-link"
  resource_group_name   = data.azurerm_virtual_network.vnet.resource_group_name
  private_dns_zone_name = var.private_endpoint.private_dns_zone_name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
  registration_enabled  = false
  depends_on            = [azurerm_private_endpoint.acr_private_endpoint]
}

# Conditional Private DNS A Record
resource "azurerm_private_dns_a_record" "acr_dns_a_record" {
  count               = var.private_endpoint.enable ? 1 : 0
  name                = azurerm_container_registry.acr.name
  zone_name           = var.private_endpoint.private_dns_zone_name
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  records             = [data.azurerm_private_endpoint_connection.private_ip1[0].private_service_connection[0].private_ip_address]
  ttl                 = 300
  depends_on          = [azurerm_private_endpoint.acr_private_endpoint]
}