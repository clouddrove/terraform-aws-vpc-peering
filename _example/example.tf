provider "aws" {
  region = "eu-west-1"
}

module "vpc-peering" {
  source = "../"

  name        = "vpc-peering"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  requestor_vpc_id = "vpc-XXXXXXXXXXXXXXXXX"
  acceptor_vpc_id  = "vpc-XXXXXXXXXXXXXXXXXcd"
}
