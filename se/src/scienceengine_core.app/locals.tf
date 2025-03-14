locals {
  default_tags = {
    "Environment" = var.environment
    "Project"     = var.project
    "CreatedBy"   = "Terraform"
  }
  location_map = {
    "West Europe"    = "weu"
    "North Europe"   = "neu"
    "East US"        = "eus"
    "West US"        = "wus"
    "UK South"       = "uks"
  }
  location_code = local.location_map[var.location]

  allow_ip_rule = concat(["${data.azurerm_public_ip.firewall_public_ip.ip_address}/32"], var.data.allow_ip)

  updated_rg = {
    for rg_name, rg_value in var.rg :
    rg_name => "${rg_value}-${lower(var.environment)}"
  }

  dynamic_kv_subnet_names = [
    for subnet in var.keyvault.allow_subnets : (
      subnet == "AzureADOSelfhostedAgentSubnet" ||
      subnet == "AzureFirewallSubnet" ||
      subnet == "AzureBastionSubnet"
      ? subnet
      : "${var.project}${subnet}Subnet"
    )
  ]

  dynamic_sa_subnet_names = [
    for subnet in var.storage_account.allow_subnets : (
      subnet == "AzureADOSelfhostedAgentSubnet" ||
      subnet == "AzureFirewallSubnet" ||
      subnet == "AzureBastionSubnet"
      ? subnet
      : "${var.project}${subnet}Subnet"
    )
  ]

  #Secrets and Certificates
secret_maps = {
  "RCServicePrincipalClientSecret" = {
    name  = "RCServicePrincipalClientSecret"
    value = var.SE_App_Reg_client_secret
  }
  "SEAPIServicePrincipalClientSecret" = {
    name  = "SEAPIServicePrincipalClientSecret"
    value = var.SE_Client_API_App_Reg_client_secret
  }
  "DevOpsServicePrincipalClientSecret" = {
    name  = "DevOpsServicePrincipalClientSecret"
    value = var.SE_DevOps_App_Reg_client_secret
  }
}

certificates_map = lower(var.upload_cert) ? {
  "TlsCertificate" = {
    name      = "TlsCertificate"
    file_path = "../../../Certificates/certs/redcanvas-${lower(var.environment)}.novonordisk.com.pfx"
    password  = ""
  },
  "ClusterCertificate" = {
    name      = "ClusterCertificate"
    file_path = "../../../Certificates/certs/int.redcanvas-${lower(var.environment)}.novonordisk.com.pfx"
    password  = ""
  },
  "CanvasStartup-S2SclientCert" = {
    name      = "CanvasStartup-S2SclientCert"
    file_path = "../../../Certificates/certs/int.redcanvas-${lower(var.environment)}.novonordisk.com.pfx"
    password  = ""
  }
} : {}


# --------------------------------------

  # Retrieve existing certificates if var.upload_cert is false
  # existing_certificates = !var.upload_cert ? {
  #   for cert_key, cert_data in data.azurerm_key_vault_certificate.existing_certificates :
  #   cert_key => {
  #     name      = cert_data.name
  #     file_path = cert_data.certificate_data
  #     password  = "" # Define password if necessary
  #   }
  # } : {}
# certificate_maps = {
#   "TlsCertificate" = {
#     name      = "TlsCertificate"
#     file_path = tls_cert_exists ? filebase64("../../../Certificates/certs/redcanvas-${lower(var.environment)}.novonordisk.com.pfx") : null
#     password  = "pfxIZhxnQaTW"
#   },
#   "ClusterCertificate" = {
#     name      = "ClusterCertificate"
#     file_path = cluster_cert_exists ? filebase64("../../../Certificates/certs/int.redcanvas-${lower(var.environment)}.novonordisk.com.pfx") : null
#     password  = ""
#   },
#   "CanvasStartup-S2SclientCert" = {
#     name      = "CanvasStartup-S2SclientCert"
#     file_path = canvas_startup_cert_exists ? filebase64("../../../Certificates/certs/int.redcanvas-${lower(var.environment)}.novonordisk.com.pfx") : null
#     password  = ""
#   }
# }

  # certificate_maps = {
  #   "TlsCertificate" = {
  #     name      = "TlsCertificate"
  #     file_path = var.upload_cert ? filebase64("../../../Certificates/certs/redcanvas-${lower(var.environment)}.novonordisk.com.pfx") : data.azurerm_key_vault_certificate.existing_certificates["TlsCertificate"].certificate_data
  #     password  = "pfxIZhxnQaTW"
  #   },
  #   "ClusterCertificate" = {
  #     name      = "ClusterCertificate"
  #     file_path = var.upload_cert ? filebase64("../../../Certificates/certs/int.redcanvas-${lower(var.environment)}.novonordisk.com.pfx") : data.azurerm_key_vault_certificate.existing_certificates["ClusterCertificate"].certificate_data
  #     password  = ""
  #   },
  #   "CanvasStartup-S2SclientCert" = {
  #     name      = "CanvasStartup-S2SclientCert"
  #     file_path = var.upload_cert ? filebase64("../../../Certificates/certs/int.redcanvas-${lower(var.environment)}.novonordisk.com.pfx") : data.azurerm_key_vault_certificate.existing_certificates["CanvasStartup-S2SclientCert"].certificate_data
  #     password  = ""
  #   }
  # }

    # Add certificates from the data block if upload_cert is false
  # existing_certificates = var.upload_cert ? {} : {
  #   for cert_key, cert_data in data.azurerm_key_vault_certificate.existing_certificates :
  #   cert_key => {
  #     name      = cert_data.name
  #     file_path = cert_data.certificate_data
  #     password  = "" # Define password if necessary
  #   }
  # }
  
  # certificate_maps = var.upload_cert ? {
  #   "TlsCertificate" = {
  #     name      = "TlsCertificate"
  #     file_path = filebase64("../../../Certificates/certs/redcanvas-${lower(var.environment)}.novonordisk.com.pfx")
  #     password  = "pfxIZhxnQaTW"
  #   },
  #   "ClusterCertificate" = {
  #     name      = "ClusterCertificate"
  #     file_path = filebase64("../../../Certificates/certs/int.redcanvas-${lower(var.environment)}.novonordisk.com.pfx")
  #     password  = ""
  #   },
  #   "CanvasStartup-S2SclientCert" = {
  #     name      = "CanvasStartup-S2SclientCert"
  #     file_path = filebase64("../../../Certificates/certs/int.redcanvas-${lower(var.environment)}.novonordisk.com.pfx")
  #     password  = ""
  #   }
  # } : {}

  # existing_certificates = var.upload_cert ? {} : {
  #   for cert_key, cert_data in data.azurerm_key_vault_certificate.existing_certificates :
  #   cert_key => {
  #     name      = cert_data.name
  #     file_path = cert_data.certificate_data
  #     password  = "" # Define password if necessary
  #   }
  # }
  # certificate_maps = merge(
  #   var.upload_cert ? {} : local.existing_certificates,
  #   var.upload_cert ? {
  #     "TlsCertificate" = {
  #       name      = "TlsCertificate"
  #       file_path = filebase64("../../../Certificates/certs/redcanvas-${lower(var.environment)}.novonordisk.com.pfx")
  #       password  = "pfxIZhxnQaTW"
  #     },
  #     "ClusterCertificate" = {
  #       name      = "ClusterCertificate"
  #       file_path = filebase64("../../../Certificates/certs/int.redcanvas-${lower(var.environment)}.novonordisk.com.pfx")
  #       password  = ""
  #     },
  #     "CanvasStartup-S2SclientCert" = {
  #       name      = "CanvasStartup-S2SclientCert"
  #       file_path = filebase64("../../../Certificates/certs/int.redcanvas-${lower(var.environment)}.novonordisk.com.pfx")
  #       password  = ""
  #     }
  #   } : {}
  # )

  resources_to_lock = {
    key_vault = {
      name       = "lock-${module.keyvault.name}"
      scope      = module.keyvault.id
      lock_level = "CanNotDelete"
      enabled    = var.keyvault.resource_lock
    }
    storage_account = {
      name       = "lock-${module.storage_account.name}"
      scope      = module.storage_account.id
      lock_level = "CanNotDelete"
      enabled    = var.storage_account.resource_lock
    }
  }

  network_ids_map = {
    "vnet"    = data.azurerm_virtual_network.vnet.id
    "vnet-rg" = data.azurerm_resource_group.se_net_rg.id
    "aag-pip" = data.azurerm_public_ip.aag_public_ip.id
  }
}
