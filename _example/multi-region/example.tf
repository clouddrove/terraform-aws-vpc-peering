provider "aws" {
  region = "eu-west-1"
}

module "vpc-peering" {
  source           = "./../.."
  name             = "vpc-peering"
  environment      = "prod"
  label_order      = ["environment", "name"]
  requestor_vpc_id = "vpc-032b6f35554a15e04"

  acceptor_vpc_id  = "vpc-0770ef28023d8c920"
  accept_region    = "ap-south-1"
  auto_accept      = false
}
