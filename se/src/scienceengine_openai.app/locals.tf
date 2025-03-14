locals {
  default_tags = {
    "Environment" = var.environment
    "Project"     = var.project
    "CreatedBy"   = "Terraform"
  }
  locations_map = var.location_map
  # assign_region =  {
  #   for key, value in var.openai : key => (
  #     contains(keys(module.network), value.region) ? value.region : var.default_region
  #   )
  # }
  assign_region = {
    for key, value in var.openai : key => {
      region = try(var.network_data[value.region], null) != null ? value.region : var.default_region
    }
  }

  # enable_cmk = false
}




#   updated_rg = {
#     for rg_name, rg_value in var.rg :
#     rg_name => "${rg_value}-${lower(var.environment)}"
#   }

#   dns_zones = {
#   "openai" = "privatelink.openai.azure.com"
#   }

#   dynamic_openai_subnet_names = [
#     for subnet in var.allow_subnets : (
#       subnet == "AzureADOSelfhostedAgentSubnet" ||
#       subnet == "AzureFirewallSubnet" ||
#       subnet == "AzureBastionSubnet"
#       ? subnet
#       : "${var.project}${subnet}Subnet"
#     )
#   ]

# }