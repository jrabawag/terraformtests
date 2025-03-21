output "name" {
  value = azurerm_cognitive_account.this.name
}

output "resource_group_name" {
  value = azurerm_cognitive_account.this.resource_group_name
}

output "openai-endpoint" {
  value = azurerm_cognitive_account.this.endpoint
}

output "cognitive_account_identity" {
  description = "The identity block exports the Principal ID and the Tenant ID associated with this Managed Service Identity."
  value       = try(azurerm_cognitive_account.this.identity[0], null)
}

output "openai_endpoint" {
  description = "The endpoint used to connect to the Cognitive Service Account."
  value       = azurerm_cognitive_account.this.endpoint
}

output "openai_id" {
  description = "The ID of the Cognitive Service Account."
  value       = azurerm_cognitive_account.this.id
}

output "openai_primary_key" {
  description = "The primary access key for the Cognitive Service Account."
  sensitive   = true
  value       = azurerm_cognitive_account.this.primary_access_key
}

output "openai_secondary_key" {
  description = "The secondary access key for the Cognitive Service Account."
  sensitive   = true
  value       = azurerm_cognitive_account.this.secondary_access_key
}

output "openai_subdomain" {
  description = "The subdomain used to connect to the Cognitive Service Account."
  value       = azurerm_cognitive_account.this.custom_subdomain_name
}

output "public_network_access_enabled" {
  description = "The subdomain used to connect to the Cognitive Service Account."
  value       = azurerm_cognitive_account.this.public_network_access_enabled
}

output "local_auth_enabled" {
  description = "The subdomain used to connect to the Cognitive Service Account."
  value       = azurerm_cognitive_account.this.local_auth_enabled
}

output "openai_deployments" {
  description = "A map of OpenAI models with deployment details."
  value = {
    for k, v in azurerm_cognitive_deployment.this :
    v.name => {
      cognitive_account_id = v.cognitive_account_id
      deployment_id        = v.name
    }
  }
}

# output "private_ip_addresses" {
#   description = "A map dictionary of the private IP addresses for each private endpoint."
#   value = {
#     for key, pe in azurerm_private_endpoint.this : key => pe.private_service_connection[0].private_ip_address
#   }
# }