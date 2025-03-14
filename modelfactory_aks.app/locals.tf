locals {
  default_tags = {
    "Environment" = var.environment
    "Project"     = var.project
    "CreatedBy"   = "Terraform"
  }

  # short location code
  location_code = {
    "westeurope" = "weu"
    "westus"     = "wus"
    "uksouth"    = "uks"
  }

  # full location code
  locations_map = {
    "weu" = "westeurope"
    "wus" = "westus"
    "uks" = "uksouth"
  }

  # Subnets
  # subnet_list = flatten([
  #   for region, config in var.subnets : [
  #     for subnet in config.subnets : {
  #       region = region
  #       name   = subnet
  #     }
  #   ] if config.create_subnets
  # ])

  # vnet_prefix_length = regex("[0-9]+$", tolist(azurerm_virtual_network.vnet["uks"].address_space)[0])
#   subnet_list = [
#   for subnet_name, subnet in var.subnets : {
#     key    = "${subnet.network}-${subnet.name}"
#     region = subnet.network
#     name   = subnet.name
#     idx    = index(keys(var.subnets), subnet_name)
#     vnet_prefix_length = regex("[0-9]+$", tolist(azurerm_virtual_network.vnet["uks"].address_space)[0])
#     cidr   = cidrsubnet(
#       local.subnet_list.vnet_prefix_length,  # Base VNet address space
#       subnet.mask - regex("[0-9]+$", tolist(azurerm_virtual_network.vnet[subnet.network].address_space)[0]),  # Subnet mask adjustment
#       index(keys(var.subnets), subnet_name) # - 1  # Unique offset for each subnet
#     )
#   }
# ]
 

  # base_cidr_block = "10.10.0.0/19"


  # prefix_length = {
  #   for subnet_name, subnet in var.subnets : subnet_name => tonumber(regex("[0-9]+$", local.base_cidr_block))
  # }

  # newbit = {
  #   for subnet_name, subnet in var.subnets : subnet_name => subnet.mask - local.prefix_length[subnet_name]
  # }

  # # Calculate the netnum for each subnet
  # netnum = {
  #   for subnet_name, subnet in var.subnets : subnet_name => index(keys(var.subnets), subnet_name)
  # }

  # subnet_list = [
  #   for subnet_name, subnet in var.subnets : {
  #     key    = "${subnet.network}-${subnet.name}"
  #     region = subnet.network
  #     name   = subnet.name
  #     base_cidr_block = local.base_cidr_block
  #     prefix_length = local.prefix_length[subnet_name]
  #     newbit = local.newbit[subnet_name]
  #     netnum = local.netnum[subnet_name]
  #     cidr   = cidrsubnet(
  #       local.base_cidr_block,
  #       local.newbit[subnet_name],
  #       local.netnum[subnet_name]
  #     )
  #   }
  # ]




  # subnet_address_prefixes = {
  # subnet_3 = cidrsubnet(local.base_cidr_block, 2, 0)  # /21 (10.10.2.0/21)
  # subnet_1 = cidrsubnet(local.base_cidr_block, 5, 1)  # /24 (10.10.0.0/24)
  # subnet_2 = cidrsubnet(local.base_cidr_block, 5, 2)  # /24 (10.10.1.0/24)

  # }
  # base_cidr_block    = "10.10.0.0/19"
  # base_prefix_length = tonumber(split("/", local.base_cidr_block)[1]) # Extracts "19"

  # # Existing subnets (simulated, replace with your actual variable)
  # existing_subnets = [
  #   "10.10.2.0/24"
  # ]

  # # Get the last allocated subnet's netnum
  # last_netnum = max([
  #   for subnet in local.existing_subnets :
  #   tonumber(split("/", subnet)[1]) == 24 ? (tonumber(split(".", subnet)[2]) / 1) :
  #   tonumber(split("/", subnet)[1]) == 21 ? (tonumber(split(".", subnet)[2]) / 8) : 0
  # ]...)

  # # Allocate next available netnum for /21
  # next_netnum_21 = local.last_netnum + 1

  # # Allocate next available netnum for /24 (after /21)
  # next_netnum_24_1 = local.next_netnum_21 + 1
  # next_netnum_24_2 = local.next_netnum_24_1 + 1

  # # New subnet allocations
  # new_subnet_21 = cidrsubnet(local.base_cidr_block, 2, local.next_netnum_21) # /21
  # new_subnet_24_1 = cidrsubnet(local.base_cidr_block, 5, local.next_netnum_24_1) # /24
  # new_subnet_24_2 = cidrsubnet(local.base_cidr_block, 5, local.next_netnum_24_2) # /24

  # subnet_list = {
  #   "system"   = cidrsubnet(local.base_cidr_block, 2, local.next_netnum_21)   # /21
  #   "cpu" = cidrsubnet(local.base_cidr_block, 5, local.next_netnum_24_1) # /24
  #   "gpu" = cidrsubnet(local.base_cidr_block, 5, local.next_netnum_24_2) # /24
  # }
  
  # Define the base CIDR block
   # Define the base CIDR block

 base_cidr_block = "10.3.0.0/19"  # Correct address space
  base_prefix_length = tonumber(split("/", local.base_cidr_block)[1]) # Extracts "20"

  # Calculate the next subnet
  next_netnum_21 = 1  # The second /21 subnet in the /20 space

  # # Define new subnet
  # subnet_list = {
  #   aksSystem = {
  #     cidr   = cidrsubnet(local.base_cidr_block, 3, 2) # /21
  #     region = var.subnets["aksSystem"].network
  #   },
  #   aksSystem = {
  #     cidr   = cidrsubnet(local.base_cidr_block, 3, 2) # /21
  #     region = var.subnets["aksSystem"].network
  #   },
  #   aksSystem = {
  #     cidr   = cidrsubnet(local.base_cidr_block, 3, 2) # /21
  #     region = var.subnets["aksSystem"].network
  #   }
  # }



  subnet_list = {
    aksSystem = {
      cidr   = "10.3.32.0/21"
      region = var.subnets["aksSystem"].network
    }
    aksCPU = {
      cidr   = "10.3.40.0/24"  
      region = var.subnets["CPUaksnodepools"].network
    }
    aksGPU = {
      cidr   = "10.3.41.0/24"  
      region = var.subnets["GPUaksnodepools"].network
    }
  }


  default_data_region = var.region_kvsecrets
}
# output "vnet_prefix_length" {
#   value = local.vnet_prefix_length
# }

  # # Get the last allocated subnet's netnum
  # last_netnum = max([
  #   for subnet in local.existing_subnets :
  #   tonumber(split("/", subnet)[1]) == 24 ? (tonumber(split(".", subnet)[2]) / 1) :
  #   tonumber(split("/", subnet)[1]) == 21 ? (tonumber(split(".", subnet)[2]) / 8) : 0
  # ]...)

  # Manually set next available netnum for /21 to ensure it starts at 10.10.24.0/21

output "last_subnet" {
  value = local.subnet_list
}

# output "last_subnet_se" {
#   value = local.subnet_address_prefixes
# }
  # subnet_offset = 0
  # subnet_list = flatten([
  #   for subnet_name, subnet in var.subnets : [
  #     region = subnet.network
  #     name   = subnet.name
  #     mask   = subnet.mask
  #     # Find the corresponding virtual network based on the subnet region
  #     vnet_address_space = element(data.azurerm_virtual_network.vnet[subnet.network].address_space, 0)
  #     cidr   = cidrsubnet(vnet_address_space, subnet.mask, local.subnet_offset + index(keys(var.subnets), subnet_name))
  #   ] if !subnet.existing
  # ])

  # # Extract the last subnet within each vnet instance
  # last_subnet = {
  #   for subnet_name, subnet in var.subnets : subnet.network => cidrsubnet(element(data.azurerm_virtual_network.vnet[subnet.network].address_space, 0), subnet.mask, local.subnet_offset + length(var.subnets) - 1)
  # }



  ## region of the KV: for storing secrets