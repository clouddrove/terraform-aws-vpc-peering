provider "aws" {
  region = "eu-west-1"
}

module "vpc-peering" {
  source           = "./../.."
  name             = "vpc-peering"
  environment      = "prod"
  label_order      = ["environment", "name"]
  requestor_vpc_id = "vpc-xxxxxxxxxxxxxxxx"

  acceptor_vpc_id = "vpc-xxxxxxxxxxxxxxxxx"
  accept_region   = "ap-south-1"
  auto_accept     = false
}
