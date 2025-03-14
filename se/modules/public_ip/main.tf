terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  required_version = ">= 0.14.9"
}

# Public IP Prefix
resource "azurerm_public_ip_prefix" "prefix" {
  name                = "${var.pip_name}-prefix"
  location            = var.location
  resource_group_name = var.resource_group_name
  prefix_length       = var.prefix_length
  zones               = var.zones
  tags                = var.tags
}

# Public IP
resource "azurerm_public_ip" "pip" {
  name                = var.pip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.allocation_method
  sku                 = var.sku
  zones               = var.zones
  public_ip_prefix_id = azurerm_public_ip_prefix.prefix.id
  tags                = var.tags

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "pip_settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_public_ip.pip.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DDoSProtectionNotifications"
  }

  enabled_log {
    category = "DDoSMitigationFlowLogs"
  }

  enabled_log {
    category = "DDoSMitigationReports"
  }

  metric {
    category = "AllMetrics"
  }

  lifecycle {
    ignore_changes = [
      log_analytics_workspace_id,
      enabled_log,
      metric,
    ]
  }
}
