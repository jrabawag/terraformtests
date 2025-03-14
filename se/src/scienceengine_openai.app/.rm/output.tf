# output "network_data_subnets" {
#   value = module.network_data.subnet_ids
# }

output "public_ip_location" {
  value = data.azurerm_public_ip.firewall_public_ip.ip_address
}
