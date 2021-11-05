provider "aws" {
  region = "eu-west-1"
}

module "vpc-peering" {
  source           = "./../../"
  name             = "vpc-peering"
  environment      = "test"
  label_order      = ["name", "environment"]
  requestor_vpc_id = "vpc-046df390b2a5d3586"
  acceptor_vpc_id  = "vpc-05b404dd9a16f6060"
}
