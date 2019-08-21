module "vpc-peering" {
  source           = "../"
  name             = "vpc-peering"
  environment      = "dmz<->dev"
  organization     = "clouddrove"
  requestor_vpc_id = "vpc-4234234324"
  acceptor_vpc_id  = "vpc-3242343233"
}
