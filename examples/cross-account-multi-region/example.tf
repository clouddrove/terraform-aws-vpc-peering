provider "aws" {
  region = "ap-south-1"
}

locals {
  name        = "peering"
  environment = "test"
}

##-----------------------------------------------------------------------------
## cross-account multi-region vpc-peering module call.
## Requestor VPC is in ap-south-1, acceptor VPC is in eu-north-1,
## and both VPCs are in different AWS accounts.
## auto_accept = false  : cross-account peering cannot be auto-accepted.
## accept_region        : region of the acceptor VPC (eu-north-1).
## peer_owner_id        : AWS account ID of the acceptor VPC owner (Account B).
##-----------------------------------------------------------------------------
module "vpc-peering" {
  source = "./../../"

  name             = local.name
  environment      = local.environment
  requestor_vpc_id = "vpc-xxxxxxxxxxxx"
  acceptor_vpc_id  = "vpc-xxxxxxxxxxxx"
  accept_region    = "eu-north-1"
  auto_accept      = false
  peer_owner_id    = "XXXXXXXXXXXX" # Replace with acceptor AWS account ID
}