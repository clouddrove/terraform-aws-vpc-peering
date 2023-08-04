provider "aws" {
  region = "ap-south-1"
}

module "vpc-peering" {
  source           = "./../.."
  name             = "vpc-peering"
  environment      = "prod"
  label_order      = ["environment", "name"]
  requestor_vpc_id = "vpc-xxxxxxxxxxxx"

  acceptor_vpc_id = "vpc-xxxxxxxxxxxxx"
  accept_region   = "eu-north-1"
  auto_accept     = false
}
