#RBAC
module "rg_sedep_rbac" {
  for_each = { for rbac in var.rg_rbac : "${rbac.object_id}-${rbac.role_name}" => rbac }
  source               = "../../modules/rbac"
  scope                = data.azurerm_resource_group.sedeploy_rg.id
  role_definition_name = each.value.role_name
  principal_id         = each.value.object_id
}

module "rg_se_rbac" {
  for_each = { for rbac in var.rg_rbac : "${rbac.object_id}-${rbac.role_name}" => rbac }
  source               = "../../modules/rbac"
  scope                = data.azurerm_resource_group.se_rg.id
  role_definition_name = each.value.role_name
  principal_id         = each.value.object_id
}

module "network_rbac" {
  for_each = { for rbac in var.network_rbac : "${rbac.role_name}-${rbac.scope}" => rbac }
  source               = "../../modules/rbac"
  scope                = local.network_ids_map[each.value.scope]
  role_definition_name = each.value.role_name
  principal_id         = each.value.object_id
}

module "additional_se_rbac" {
  for_each = merge(flatten([
    for rbac_key, rbac_value in var.additional_se_rbac : [
      for role in rbac_value.role_name : {
        "${rbac_value.object_id}-${role}" = {
          object_id = rbac_value.object_id
          role_name = role
        }
      }
    ]
  ])...)
  source               = "../../modules/rbac"
  scope                = data.azurerm_resource_group.se_rg.id
  role_definition_name = each.value.role_name
  principal_id         = each.value.object_id
}


#KEY VAULT
module "keyvault" {
  source                         = "../../modules/key_vault"
  name                           = "kv${var.shortproject}${local.location_code}${var.keyvault.name}${lower(var.environment)}"
  resource_group_name            = local.updated_rg["se"]
  location                       = var.location
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  sku_name                       = var.keyvault.sku_name
  soft_delete_retention_days     = var.keyvault.soft_delete_retention_days
  purge_protection_enabled       = var.keyvault.purge_protection_enabled
  bypass                         = var.keyvault.firewall ? "AzureServices" : "None"
  virtual_network_subnet_ids     = var.keyvault.firewall ? values(data.azurerm_subnet.allowed_kv_subnet)[*].id : []
  ip_rules                       = var.keyvault.firewall ? [] : local.allow_ip_rule
  default_action                 = var.keyvault.firewall ? "Allow" : "Deny"
  log_analytics_workspace_enable = true
  enable_rbac_authorization      = true
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.log_workspace.id
  public_network_access_enabled  = var.keyvault.public_network_access_enabled
  private_endpoint = {
    enable                = true
    private_dns_zone_id   = data.azurerm_private_dns_zone.dns_zones["keyvault"].id
    private_dns_zone_name = data.azurerm_private_dns_zone.dns_zones["keyvault"].name
    vnet_name             = data.azurerm_virtual_network.vnet.name
    vnet_rg               = data.azurerm_virtual_network.vnet.resource_group_name
    subnet_id             = data.azurerm_subnet.pe_subnet.id
  }
}
module "kv_rbac" {
  for_each             = { for rbac in var.keyvault.rbac : rbac.object_id => rbac }
  source               = "../../modules/rbac"
  scope                = module.keyvault.id
  role_definition_name = each.value.role
  principal_id         = each.value.object_id
  depends_on           = [module.keyvault]
}

#Secrets
module "sfpassword" {
  source = "../../modules/random_password"
}
module "kv_vm_secrets" {
  source = "../../modules/key_vault_secrets"

  kv_id = module.keyvault.id
  secrets = {
    username = {
      name  = "ADOselfhosted-username"
      value = var.adovm.user_name
    }
    password = {
      name  = "ADOselfhosted-password"
      value = module.vmpassword.password
    }
    sf_password = {
      name  = "virtualMachineScaleSetPassword"
      value = module.sfpassword.password
    }
  }
  depends_on = [module.keyvault, module.kv_rbac]
}
module "kv_sp_secrets" {
  source     = "../../modules/key_vault_secrets"
  kv_id      = module.keyvault.id
  secrets    = local.secret_maps
  depends_on = [module.keyvault, module.kv_rbac]
}

#Certificates
module "key_vault_certificates" {
  source       = "../../modules/key_vault_certificate_import"
  kv_id        = module.keyvault.id
  certificates = local.certificates_map
  depends_on   = [module.keyvault, module.kv_rbac]
}

#Storage Account
module "storage_account" {
  source                         = "../../modules/storage_account"
  name                           = "sa${var.shortproject}${local.location_code}${var.storage_account.name}${lower(var.environment)}"
  location                       = var.location
  resource_group_name            = local.updated_rg["se_deploy"]
  account_tier                   = var.storage_account.account_tier
  replication_type               = var.storage_account.replication_type
  is_hns_enabled                 = var.storage_account.is_hns_enabled
  account_kind                   = var.storage_account.account_kind
  virtual_network_subnet_ids     = var.storage_account.firewall ? values(data.azurerm_subnet.allowed_sa_subnet)[*].id : []
  ip_rules                       = var.storage_account.firewall ? local.allow_ip_rule : []
  default_action                 = var.storage_account.firewall ? "Deny" : "Allow"
  log_analytics_workspace_enable = true
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.log_workspace.id
  tags                           = local.default_tags
  containers                     = var.storage_account.containers
  private_endpoint = {
    enable                = false #Exempted
    private_dns_zone_id   = data.azurerm_private_dns_zone.dns_zones["storage_blob"].id
    private_dns_zone_name = data.azurerm_private_dns_zone.dns_zones["storage_blob"].name
    vnet_name             = data.azurerm_virtual_network.vnet.name
    vnet_rg               = data.azurerm_virtual_network.vnet.resource_group_name
    subnet_id             = data.azurerm_subnet.pe_subnet.id
  }
}
module "sa_rbac" {
  for_each             = { for rbac in var.storage_account.rbac : rbac.object_id => rbac }
  source               = "../../modules/rbac"
  scope                = module.storage_account.id
  role_definition_name = each.value.role
  principal_id         = each.value.object_id
  depends_on           = [module.storage_account]
}


#Application Insights
module "application_insights" {
  source              = "../../modules/application_insights"
  name                = "appi-${var.shortproject}-${local.location_code}-${var.data.appinsights_name}-${lower(var.environment)}"
  location            = var.location
  resource_group_name = local.updated_rg["se_deploy"]
  workspace_id        = data.azurerm_log_analytics_workspace.log_workspace.id
  tags                = local.default_tags
}

# ADO selfhosted
module "vmpassword" {
  source = "../../modules/random_password"
}
module "ado_selfhosted" {
  source               = "../../modules/virtual_machine"
  vm_name              = "vm-${var.shortproject}-${var.adovm.name}-${lower(var.environment)}"
  location             = data.azurerm_virtual_network.vnet.location
  subnet_id            = data.azurerm_subnet.adovm_subnet.id
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  username             = var.adovm.user_name
  password             = module.vmpassword.password
  storage_account_type = var.adovm.storage_account_type
  vm_size              = var.adovm.size
  tags                 = local.default_tags
  source_image_id      = data.azurerm_shared_image.nnwin2019.id
  enable_remote_exec   = true
  remote_exec_commands = var.adovm.exec_command
}

# 

# Generate SAS Token for the Blob
data "azurerm_storage_account_sas" "sas" {
  connection_string = module.storage_account.primary_connection_string
  https_only        = true
  signed_version    = "2020-02-10"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = true
    table = false
    file  = true
  }

  start  = "2024-12-23T00:00:00Z"
  expiry = "2025-12-23T00:00:00Z"

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = true
    add     = false
    create  = true
    update  = true
    process = false
    tag     = true
    filter  = false
  }
}


#--------------------------------------


# # Upload the PowerShell script as a blob
# resource "azurerm_storage_blob" "ps_script" {
#   name                   = "selfhosted.ps1"
#   storage_account_name   = module.storage_account.name
#   storage_container_name = module.storage_account.container_names["vm-scripts"]
#   type                   = "Block"
#   source                 = "../../../scripts/selfhosted.ps1"
# }

# resource "azurerm_virtual_machine_run_command" "rc1" {
#   location           = data.azurerm_virtual_network.vnet.location
#   name               = "test-vmrc"
#   virtual_machine_id = module.ado_selfhosted.vm_id
#   run_as_password    = module.vmpassword.password
#   run_as_user        = var.adovm.user_name

#   source {
#     script_uri = "https://${module.storage_account.name}.blob.core.windows.net/vm-scripts/selfhosted.ps1?${data.azurerm_storage_account_sas.sas.sas}"
#   }
# }

#--------------------






































# resource "azurerm_virtual_machine_extension" "ado_ps_script" {
#   name                       = "se-install-app"
#   virtual_machine_id         = module.ado_selfhosted.vm_id
#   publisher                  = "Microsoft.Compute"
#   type                       = "CustomScriptExtension"
#   type_handler_version       = "1.10"
#   settings = <<SETTINGS
# {
#   "fileUris": ["https://${module.storage_account.name}.blob.core.windows.net/${module.storage_account.container_ids["vm-scripts"]}/selfhosted.ps1?${data.azurerm_storage_account_sas.sas.sas}"],
#   "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File selfhosted.ps1"
# }
# SETTINGS
# }

# resource "azurerm_virtual_machine_run_command" "rc2" {
#   location           = data.azurerm_virtual_network.vnet.location
#   name               = "test-vmrc"
#   virtual_machine_id = module.ado_selfhosted.vm_id
#   run_as_password    = module.vmpassword.password
#   run_as_user        = var.adovm.user_name

#   source {
#     script_uri = "https://${module.storage_account.name}.blob.core.windows.net/${module.storage_account.container_ids["vm-scripts"]}/selfhosted.ps1?${data.azurerm_storage_account_sas.sas.sas}"
#   }


  # source {
  #   script = <<-EOT
  #     $desktopPath = [Environment]::GetFolderPath("Desktop")
  #     $destinationFolder = Join-Path -Path $desktopPath -ChildPath "Temp"

  #     if (!(Test-Path -Path $destinationFolder)) {
  #         Write-Host "Creating Temp folder on Desktop..."
  #         New-Item -ItemType Directory -Path $destinationFolder | Out-Null
  #     }

  #     $scriptContent = @'
  #     $desktopPath = [Environment]::GetFolderPath("Desktop")
  #     $destinationFolder = Join-Path -Path $desktopPath -ChildPath "Temp"

  #     if (!(Test-Path -Path $destinationFolder)) {
  #         Write-Host "Creating Temp folder on Desktop..."
  #         New-Item -ItemType Directory -Path $destinationFolder | Out-Null
  #     }

  #     function Download-File {
  #         param (
  #             [string]$Url,
  #             [string]$OutputPath
  #         )
  #         Write-Host "Downloading from $Url to $OutputPath..."
  #         Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
  #     }

  #     Write-Host "Starting additional tool installations..."
  #     # Add your tool installation scripts here
  #     Write-Host "All tools have been downloaded to $destinationFolder and installed successfully."
  #     '@

  #     $filePath = Join-Path -Path $destinationFolder -ChildPath "testlog.ps1"
  #     Set-Content -Path $filePath -Value $scriptContent

  #     Write-Host "The script has been saved to $filePath"

  #   EOT
  # }
# }






# -URL ${var.ADOurl} -PAT ${var.adoPAT} -POOL ${var.ADOpool} -AGENT ${var.ADOagent}



# resource "null_resource" "copy_script" {
#   depends_on = [module.ado_selfhosted]

#   provisioner "file" {
#     source      = "./scripts/selfhosted.ps1"
#     destination = "C:\\scripts\\selfhosted.ps1"

#     connection {
#       type     = "winrm"
#       user     = var.adovm.user_name
#       password = module.vmpassword.password
#       host     = module.ado_selfhosted.vm_ip
#       timeout  = "3m"
#       https    = true
#       port     = 5986
#       use_ntlm = true
#       insecure = true
#     }
#   }
# }


# resource "null_resource" "execute_script" {
#   provisioner "remote-exec" {
#     # inline = [
#     #   "powershell -ExecutionPolicy Unrestricted -File C:\\scripts\\selfhosted.ps1"
#     # ]
#     inline = [
#       "$DesktopPath = [Environment]::GetFolderPath('Desktop')",
#       "$FolderName = 'TestFolder'",
#       "$TargetFolderPath = Join-Path -Path $DesktopPath -ChildPath $FolderName",
#       "if (-Not (Test-Path -Path $TargetFolderPath)) {",
#       "  New-Item -ItemType Directory -Path $TargetFolderPath | Out-Null",
#       "  Write-Output 'Folder created successfully.'",
#       "} else {",
#       "  Write-Output 'Folder already exists.'",
#       "}"
#     ]

#     connection {
#       type     = "winrm"
#       user     = var.adovm.user_name
#       password = module.vmpassword.password
#       host     = module.ado_selfhosted.vm_ip
#       timeout  = "3m"
#       https    = true
#       port     = 5986
#       use_ntlm = true
#       insecure = true
#     }
#   }
# }