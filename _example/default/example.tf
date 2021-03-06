provider "aws" {
  region = "eu-west-1"
}

module "vpc-peering" {
  source = "./../../"

  name        = "vpc-peering"
  environment = "test"
  label_order = ["name", "environment"]

  requestor_vpc_id = "vpc-XXXXXXXXXXXXXXXXX"
  acceptor_vpc_id  = "vpc-XXXXXXXXXXXXXXXXXcd"
}
