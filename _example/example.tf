provider "aws" {
  region = "eu-west-1"
}

module "vpc-peering" {
  source = "git::https://github.com/clouddrove/terraform-aws-vpc-peering.git"

  name        = "vpc-peering"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  requestor_vpc_id = "vpc-XXXXXXXXXXXXXXXXX"
  acceptor_vpc_id  = "vpc-XXXXXXXXXXXXXXXXXcd"
}
