provider "aws" {
  region = "eu-west-1"
}

module "vpc-peering" {
  source           = "./../.."
  name             = "vpc-peering"
  environment      = "prod"
  label_order      = ["environment", "name"]
  requestor_vpc_id = "vpc-0637f4cbec95bd3cb"

  acceptor_vpc_id = "vpc-0eb3503962ae548a2"
  accept_region   = "ap-south-1"
  auto_accept     = false
}
