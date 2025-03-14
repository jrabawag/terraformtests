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
    "France Central" = "frc"
  }
  location_code = local.location_map[var.location]

  updated_rg = {
    for rg_name, rg_value in var.rg :
    rg_name => "${rg_value}-${lower(var.environment)}"
  }

}