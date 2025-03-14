output "public_ip" {
  description = "Specifies the public IP address of the virtual machine"
  value       = azurerm_windows_virtual_machine.virtual_machine.public_ip_address
}

output "username" {
  description = "Specifies the username of the virtual machine"
  value       = var.admin_username
}

output "virtual_machine_id" {
  value = azurerm_windows_virtual_machine.virtual_machine.id
}

# output "principal_id" {
#   value = azurerm_windows_virtual_machine.virtual_machine.identity[0].principal_id
# }