output "vm_id" {
  value = azurerm_windows_virtual_machine.winvm.id
}

output "vm_ip" {
  value = azurerm_windows_virtual_machine.winvm.private_ip_address
}

output "vm_said" {
  value = azurerm_windows_virtual_machine.winvm.identity[0].principal_id
}