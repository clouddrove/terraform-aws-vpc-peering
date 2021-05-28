provider "aws" {
  region = "eu-west-1"
}

module "vpc-peering" {
  source           = "./../.."
  name             = "vpc-peering"
  environment      = "prod"
  repository       = "https://registry.terraform.io/modules/clouddrove/vpc-peering/aws/0.14.0"
  label_order      = ["environment", "name"]
  requestor_vpc_id = "vpc-xxxxxxxxxxxxxxxxcd"
  acceptor_vpc_id  = "vpc-xxxxxxxxxxxxxxxxcd"
  accept_region    = "ap-south-1"
  auto_accept      = false
}
