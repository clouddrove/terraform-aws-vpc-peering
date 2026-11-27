provider "aws" {
  region = "ca-central-1"
}

locals {
  name        = "peering"
  environment = "test"
}

##-----------------------------------------------------------------------------
## default vpc-peering module call.
##-----------------------------------------------------------------------------
module "vpc_peering" {
  source = "./../../"

  name             = local.name
  environment      = local.environment
  requestor_vpc_id = "vpc-xxxxxxxxxxxxxx"
  acceptor_vpc_id  = "vpc-xxxxxxxxxxxxxx"
}
