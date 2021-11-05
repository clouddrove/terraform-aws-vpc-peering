provider "aws" {
  region = "eu-west-1"
}

module "vpc-peering" {
  source           = "./../.."
  name             = "vpc-peering"
  environment      = "prod"
  label_order      = ["environment", "name"]
  requestor_vpc_id = "vpc-0fd16d55f6338d305"

  acceptor_vpc_id  = "vpc-0d778f4497ccad77a"
  accept_region    = "ap-south-1"
  auto_accept      = false
}
