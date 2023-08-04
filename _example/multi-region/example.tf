provider "aws" {
  region = "ap-south-1"
}

module "vpc-peering" {
  source           = "./../.."
  name             = "vpc-peering"
  environment      = "prod"
  label_order      = ["environment", "name"]
  requestor_vpc_id = "vpc-09b5a7ef11a1d58b1"

  acceptor_vpc_id = "vpc-0b619d80a58b3be5a"
  accept_region   = "eu-north-1"
  auto_accept     = false
}
