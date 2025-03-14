# output "id" {
#   description = "Specifies the resource id of the private endpoint."
#   value       = azurerm_private_endpoint.this.id
# }


output "private_endpoint_config" {
  description = ""
  value = {
    for key, pe in azurerm_private_endpoint.this : key => {
      pe_name           = pe.pe_name
      pe_priv_dns_group = pe.private_dns_zone_group
      pe_private_ip     = pe.private_service_connection[0].private_ip_address
      pe_dns_config     = pe.private_dns_zone_configs
    }
  }
}