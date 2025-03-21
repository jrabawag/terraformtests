output "id" {
  value       = azurerm_log_analytics_workspace.log_analytics_workspace.id
  description = "Specifies the resource id of the log analytics workspace"
}

output "location" {
  value       = azurerm_log_analytics_workspace.log_analytics_workspace.location
  description = "Specifies the location of the log analytics workspace"
}

output "name" {
  value       = azurerm_log_analytics_workspace.log_analytics_workspace.name
  description = "Specifies the name of the log analytics workspace"
}

output "resource_group_name" {
  value       = azurerm_log_analytics_workspace.log_analytics_workspace.resource_group_name
  description = "Specifies the name of the resource group that contains the log analytics workspace"
}

output "workspace_id" {
  value       = azurerm_log_analytics_workspace.log_analytics_workspace.workspace_id
  description = "Specifies the workspace id of the log analytics workspace"
}

output "primary_shared_key" {
  value       = azurerm_log_analytics_workspace.log_analytics_workspace.primary_shared_key
  description = "Specifies the workspace key of the log analytics workspace"
  sensitive   = true
}


# output "log_analytics_workspaces" {
#   description = "Contains a map of all created Log Analytics Workspaces with their attributes"
#   value = { 
#     for workspace in azurerm_log_analytics_workspace.log_analytics_workspace :
#     workspace.name => {
#       id                  = workspace.id
#       location            = workspace.location
#       resource_group_name = workspace.resource_group_name
#       workspace_id        = workspace.workspace_id
#       primary_shared_key  = workspace.primary_shared_key
#     }
#   }
#   sensitive = true
# }
