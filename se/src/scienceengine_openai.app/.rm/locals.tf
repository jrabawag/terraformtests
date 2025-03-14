locals {
  default_tags = {
    "Environment" = var.environment
    "Project"     = var.project
    "CreatedBy"   = "Terraform"
  }
  #    "East US 2"        = "eus2"
  location_map = {
    "West Europe"    = "weu"
    "North Europe"   = "neu"
    "East US"        = "eus"
    "East US 2"      = "eus2"
    "southcentralus" = "scus"
    "West US"        = "wus"
    "UK South"       = "uks"
    "France Central" = "frc"
    "Sweden Central" = "swc"
  }


  location_code = local.location_map[var.location]

  updated_rg = {
    for rg_name, rg_value in var.rg :
    rg_name => "${rg_value}-${lower(var.environment)}"
  }


  dynamic_openai_subnet_names = [
    for subnet in var.allow_subnets : (
      subnet == "AzureADOSelfhostedAgentSubnet" ||
      subnet == "AzureFirewallSubnet" ||
      subnet == "AzureBastionSubnet"
      ? subnet
      : "${var.project}${subnet}Subnet"
    )
  ]

}