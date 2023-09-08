provider "aws" {
  region = "ap-south-1"
}

locals {
  name        = "peering"
  environment = "test"
}

##-----------------------------------------------------------------------------
## multi region vpc-peering module call.
##-----------------------------------------------------------------------------
module "vpc-peering" {
  source           = "./../.."
  name             = local.name
  environment      = local.environment
  requestor_vpc_id = "vpc-xxxxxxxxxxxx"

  acceptor_vpc_id = "vpc-xxxxxxxxxxxxx"
  accept_region   = "eu-north-1"
  auto_accept     = false
}
