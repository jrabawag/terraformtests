#Windows
resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# resource "azurerm_windows_virtual_machine" "winvm" {
#   name                = var.vm_name
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   size                = var.vm_size
#   admin_username      = var.username
#   admin_password      = var.password
#   tags                = var.tags
#   network_interface_ids = [
#     azurerm_network_interface.nic.id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = var.storage_account_type
#   }

#   dynamic "remote-exec" {

#   }
#   source_image_id = var.source_image_id

#   #source_image_reference {
#   #  publisher = "MicrosoftWindowsServer"
#   #  offer     = "WindowsServer"
#   #  sku       = "2019-Datacenter"
#   #  version   = "latest"
#   #}

#   provision_vm_agent = true
# }


# resource "azurerm_windows_virtual_machine" "winvm" {
#   name                = var.vm_name
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   size                = var.vm_size
#   admin_username      = var.username
#   admin_password      = var.password
#   tags                = var.tags
#   network_interface_ids = [
#     azurerm_network_interface.nic.id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = var.storage_account_type
#   }

#   # provisioner "remote-exec" {
#   #   inline = var.remote_exec_commands
#   # }

#   source_image_id    = var.source_image_id
#   provision_vm_agent = true
# }




resource "azurerm_windows_virtual_machine" "winvm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.username
  admin_password      = var.password
  tags                = var.tags
  source_image_id    = var.source_image_id
  provision_vm_agent = true
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }

  identity {
    type = "SystemAssigned"
  }

  # lifecycle {
  #   ignore_changes = [ 
  #    ]
  # }
#   provisioner "remote-exec" {
#     connection {
#       type     = "winrm"
#       user     = var.username
#       password = var.password
#       host     = self.public_ip_address
#       timeout  = "3m"
#       https    = true
#       port     = 5986
#       use_ntlm = true
#       insecure = true
#     }

#   inline =  [
#             "powershell -ExecutionPolicy Unrestricted -File 'C:\\adoapp\\selfhosted-ado.ps1' -Schedule"
#             ]
#  }

#   provisioner "file" {
#   source      = "../../script/selfhosted-ado.ps1"
#   destination = "C:/adoapp/selfhosted-ado.ps1"

#   connection {
#     host = "${azurerm_windows_virtual_machine.winvm.private_ip_address}"
#     timeout  = "3m"
#     type     = "winrm"
#     https    = true
#     port     = 5986
#     use_ntlm = true
#     insecure = true

#     user     = var.username
#     password = var.password
#   }
#   }
}