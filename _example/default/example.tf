provider "aws" {
  region = "ap-south-1"
}
module "vpc-peering" {
  source           = "./../../"
  name             = "vpc"
  environment      = "test"
  label_order      = ["name", "environment"]
  requestor_vpc_id = "vpc-xxxxxxxxxxxxxx"
  acceptor_vpc_id  = "vpc-xxxxxxxxxxxxxx"
}