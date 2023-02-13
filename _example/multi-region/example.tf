provider "aws" {
  region = "us-west-1"
}

module "vpc-peering" {
  source           = "./../.."
  name             = "vpc-peering"
  environment      = "prod"
  label_order      = ["environment", "name"]
  requestor_vpc_id = "vpc-0637xxxxxxxxxxxxx"

  acceptor_vpc_id = "vpc-0eb3xxxxxxxxxxxxx"
  accept_region   = "ap-south-1"
  auto_accept     = false
}
