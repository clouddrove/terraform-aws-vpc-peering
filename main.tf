# Managed By : CloudDrove
# Description : This Script is used to manage a VPC peering connection.
# Copyright @ CloudDrove. All Right Reserved.

data "aws_region" "default" {}

data "aws_caller_identity" "current" {}

locals {
  accept_region = var.auto_accept == false ? var.accept_region : data.aws_region.default.id
}

#Module      : Labels
#Description : Terraform module to create consistent naming for multiple names.
module "labels" {
  source = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.14.0"

  name        = var.name
  environment = var.environment
  attributes  = var.attributes
  repository  = var.repository
  managedby   = var.managedby
  label_order = var.label_order

}

#Module      : VPC PEERING CONNECTION
#Description : Provides a resource to manage a VPC peering connection.
resource "aws_vpc_peering_connection" "region" {
  count = var.enable_peering && var.auto_accept == false ? 1 : 0

  vpc_id        = var.requestor_vpc_id
  peer_vpc_id   = var.acceptor_vpc_id
  auto_accept   = var.auto_accept
  peer_region   = local.accept_region
  peer_owner_id = data.aws_caller_identity.current.account_id
  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s", module.labels.environment)
    }
  )
}

resource "aws_vpc_peering_connection" "default" {
  count = var.enable_peering && var.auto_accept ? 1 : 0

  vpc_id      = var.requestor_vpc_id
  peer_vpc_id = var.acceptor_vpc_id
  auto_accept = var.auto_accept
  accepter {
    allow_remote_vpc_dns_resolution = var.acceptor_allow_remote_vpc_dns_resolution
  }
  requester {
    allow_remote_vpc_dns_resolution = var.requestor_allow_remote_vpc_dns_resolution
  }
  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s", module.labels.environment)
    }
  )
}

provider "aws" {
  alias  = "peer"
  region = local.accept_region
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  count                     = var.enable_peering && var.auto_accept == false ? 1 : 0
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.region[0].id
  auto_accept               = true
  tags                      = module.labels.tags
}

#Module      : AWS VPC
#Description : Provides a VPC resource.
data "aws_vpc" "requestor" {
  count = var.enable_peering ? 1 : 0
  id    = var.requestor_vpc_id
}

#Module      : ROUTE TABLE
#Description : Provides a resource to create a VPC routing table.
data "aws_route_table" "requestor" {
  count = var.enable_peering ? length(distinct(sort(data.aws_subnet_ids.requestor[0].ids))) : 0
  subnet_id = element(
    distinct(sort(data.aws_subnet_ids.requestor[0].ids)),
    count.index
  )
}

#Module      : SUBNET ID's
#Description : Lookup requestor subnets.
data "aws_subnet_ids" "requestor" {
  count  = var.enable_peering ? 1 : 0
  vpc_id = data.aws_vpc.requestor[0].id
}

#Module      : VPC ACCEPTOR
#Description : Lookup acceptor VPC so that we can reference the CIDR.
data "aws_vpc" "acceptor" {
  provider = aws.peer
  count    = var.enable_peering ? 1 : 0
  id       = var.acceptor_vpc_id
}

#Module      : SUBNET ID's ACCEPTOR
#Description : Lookup acceptor subnets.
data "aws_subnet_ids" "acceptor" {
  provider = aws.peer
  count    = var.enable_peering ? 1 : 0
  vpc_id   = data.aws_vpc.acceptor[0].id
}

#Module      : ROUTE TABLE
#Description : Lookup acceptor route tables.
data "aws_route_table" "acceptor" {
  count    = var.enable_peering ? length(distinct(sort(data.aws_subnet_ids.acceptor[0].ids))) : 0
  provider = aws.peer
  subnet_id = element(
    distinct(sort(data.aws_subnet_ids.acceptor[0].ids)),
    count.index
  )
}

#Module      : ROUTE REQUESTOR
#Description : Create routes from requestor to acceptor.
resource "aws_route" "requestor" {
  count = var.enable_peering && var.auto_accept ? length(
    distinct(sort(data.aws_route_table.requestor.*.route_table_id)),
  ) * length(data.aws_vpc.acceptor[0].cidr_block_associations) : 0
  route_table_id = element(
    distinct(sort(data.aws_route_table.requestor.*.route_table_id)),
    ceil(
      count.index / length(data.aws_vpc.acceptor[0].cidr_block_associations),
    ),
  )
  destination_cidr_block    = data.aws_vpc.acceptor.0.cidr_block_associations[count.index % length(data.aws_vpc.acceptor[0].cidr_block_associations)]["cidr_block"]
  vpc_peering_connection_id = aws_vpc_peering_connection.default[0].id
  depends_on = [
    data.aws_route_table.requestor,
    aws_vpc_peering_connection.default,
  ]
}

resource "aws_route" "requestor-region" {
  count = var.enable_peering && var.auto_accept == false ? length(
    distinct(sort(data.aws_route_table.requestor.*.route_table_id)),
  ) * length(data.aws_vpc.acceptor[0].cidr_block_associations) : 0
  route_table_id = element(
    distinct(sort(data.aws_route_table.requestor.*.route_table_id)),
    ceil(
      count.index / length(data.aws_vpc.acceptor[0].cidr_block_associations),
    ),
  )
  destination_cidr_block    = data.aws_vpc.acceptor.0.cidr_block_associations[count.index % length(data.aws_vpc.acceptor[0].cidr_block_associations)]["cidr_block"]
  vpc_peering_connection_id = aws_vpc_peering_connection.region[0].id
  depends_on = [
    data.aws_route_table.requestor,
    aws_vpc_peering_connection.region,
  ]
}

#Module      : ROUTE ACCEPTOR
#Description : Create routes from acceptor to requestor.
resource "aws_route" "acceptor" {
  count = var.enable_peering && var.auto_accept ? length(
    distinct(sort(data.aws_route_table.acceptor.*.route_table_id)),
  ) * length(data.aws_vpc.requestor[0].cidr_block_associations) : 0
  route_table_id = element(
    distinct(sort(data.aws_route_table.acceptor.*.route_table_id)),
    ceil(
      count.index / length(data.aws_vpc.requestor[0].cidr_block_associations),
    ),
  )
  provider                  = aws.peer
  destination_cidr_block    = data.aws_vpc.requestor.0.cidr_block_associations[count.index % length(data.aws_vpc.requestor[0].cidr_block_associations)]["cidr_block"]
  vpc_peering_connection_id = aws_vpc_peering_connection.default[0].id
  depends_on = [
    data.aws_route_table.acceptor,
    aws_vpc_peering_connection.default,
  ]
}

resource "aws_route" "acceptor-region" {
  count = var.enable_peering && var.auto_accept == false ? length(
    distinct(sort(data.aws_route_table.acceptor.*.route_table_id)),
  ) * length(data.aws_vpc.requestor[0].cidr_block_associations) : 0
  route_table_id = element(
    distinct(sort(data.aws_route_table.acceptor.*.route_table_id)),
    ceil(
      count.index / length(data.aws_vpc.requestor[0].cidr_block_associations),
    ),
  )
  provider                  = aws.peer
  destination_cidr_block    = data.aws_vpc.requestor.0.cidr_block_associations[count.index % length(data.aws_vpc.requestor[0].cidr_block_associations)]["cidr_block"]
  vpc_peering_connection_id = aws_vpc_peering_connection.region[0].id
  depends_on = [
    data.aws_route_table.acceptor,
    aws_vpc_peering_connection.region,
  ]
}
