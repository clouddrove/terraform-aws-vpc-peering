provider "aws" {
  region = "ap-south-1"
}

module "vpc-peering" {
  source           = "./../../"
  name             = "vpc-peering"
  environment      = "test"
  label_order      = ["name", "environment"]
  requestor_vpc_id = "vpc-09b5a7ef11a1d58b1"
  acceptor_vpc_id  = "vpc-0784375f815f4cbb9"
}