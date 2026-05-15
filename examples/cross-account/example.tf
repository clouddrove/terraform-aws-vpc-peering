provider "aws" {
  region = "ap-south-1"
}

locals {
  name        = "peering"
  environment = "test"
}

##-----------------------------------------------------------------------------
## cross-account same-region vpc-peering module call.
## Both VPCs are in the same region (ap-south-1) but in different AWS accounts.
## auto_accept = false  : cross-account peering cannot be auto-accepted.
## accept_region        : same region as requestor since both VPCs are in ap-south-1.
## peer_owner_id        : AWS account ID of the acceptor VPC owner (Account B).
##-----------------------------------------------------------------------------
module "vpc-peering" {
  source = "./../../"

  name             = local.name
  environment      = local.environment
  requestor_vpc_id = "vpc-xxxxxxxxxxxx"
  acceptor_vpc_id  = "vpc-xxxxxxxxxxxx"
  accept_region    = "ap-south-1"
  auto_accept      = false
  peer_owner_id    = "XXXXXXXXXXXX" # Replace with acceptor AWS account ID
  acceptor_role_arn = "arn:aws:iam::ACCOUNT_B_ID:role/VPCPeeringAcceptorRole" # Replace with the actual ARN of the IAM role in Account B that has permissions to accept the peering request
}