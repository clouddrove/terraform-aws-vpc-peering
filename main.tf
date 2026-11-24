## Managed By : CloudDrove
## Description : This Script is used to manage a VPC peering connection.
## Copyright @ CloudDrove. All Right Reserved.

data "aws_region" "default" {}
data "aws_caller_identity" "current" {}

##-----------------------------------------------------------------------------
## Locals declaration to determine accept_region, peer_owner_id, the route
## tables that receive peering routes and the CIDR blocks of both VPCs.
##-----------------------------------------------------------------------------
locals {
  accept_region = var.auto_accept == false ? var.accept_region : data.aws_region.default.id
  peer_owner_id = var.peer_owner_id != "" ? var.peer_owner_id : data.aws_caller_identity.current.account_id

  ## Use the route tables supplied by the caller, otherwise every route table in the VPC.
  requestor_route_table_ids = length(var.requestor_route_table_ids) > 0 ? distinct(var.requestor_route_table_ids) : distinct(sort(flatten(data.aws_route_tables.requestor[*].ids)))
  acceptor_route_table_ids  = length(var.acceptor_route_table_ids) > 0 ? distinct(var.acceptor_route_table_ids) : distinct(sort(flatten(data.aws_route_tables.acceptor[*].ids)))

  ## All CIDR blocks (primary + secondary) associated with each VPC.
  requestor_cidr_blocks = flatten([for vpc in data.aws_vpc.requestor : [for assoc in vpc.cidr_block_associations : assoc.cidr_block]])
  acceptor_cidr_blocks  = flatten([for vpc in data.aws_vpc.acceptor : [for assoc in vpc.cidr_block_associations : assoc.cidr_block]])

  ## One route per (route table, remote CIDR) pair.
  requestor_route_count = var.enable_peering && var.create_requestor_routes ? length(local.requestor_route_table_ids) * length(local.acceptor_cidr_blocks) : 0
  acceptor_route_count  = var.enable_peering && var.create_acceptor_routes ? length(local.acceptor_route_table_ids) * length(local.requestor_cidr_blocks) : 0

  peering_connection_id = var.auto_accept ? join("", aws_vpc_peering_connection.default[*].id) : join("", aws_vpc_peering_connection.region[*].id)
  peering_name          = format("%s-peering", module.labels.id)
}

##-----------------------------------------------------------------------------
## Labels module called that will be used for naming and tags.
##-----------------------------------------------------------------------------
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.1"

  name        = var.name
  environment = var.environment
  attributes  = var.attributes
  repository  = var.repository
  managedby   = var.managedby
  label_order = var.label_order
  extra_tags  = var.extra_tags
}

##-----------------------------------------------------------------------------
## Provides a resource to manage a VPC peering connection.
## Used when: auto_accept = true (same account, same region).
##-----------------------------------------------------------------------------
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
      "Name" = local.peering_name
    }
  )
}

##-----------------------------------------------------------------------------
## provides details about a requestor VPC.
##-----------------------------------------------------------------------------
data "aws_vpc" "requestor" {
  count = var.enable_peering ? 1 : 0
  id    = var.requestor_vpc_id
}

##-----------------------------------------------------------------------------
## provides details about a acceptor VPC.
##-----------------------------------------------------------------------------
data "aws_vpc" "acceptor" {
  provider = aws.peer
  count    = var.enable_peering ? 1 : 0
  id       = var.acceptor_vpc_id
}

##-----------------------------------------------------------------------------
## Looks up all acceptor route table ids.
## Skipped when acceptor_route_table_ids is supplied.
##-----------------------------------------------------------------------------
data "aws_route_tables" "acceptor" {
  provider = aws.peer
  count    = var.enable_peering && length(var.acceptor_route_table_ids) == 0 ? 1 : 0
  vpc_id   = join("", data.aws_vpc.acceptor[*].id)
}

##-----------------------------------------------------------------------------
## Looks up all requestor route table ids.
## Skipped when requestor_route_table_ids is supplied.
##-----------------------------------------------------------------------------
data "aws_route_tables" "requestor" {
  count  = var.enable_peering && length(var.requestor_route_table_ids) == 0 ? 1 : 0
  vpc_id = join("", data.aws_vpc.requestor[*].id)
}

##-----------------------------------------------------------------------------
## Provides a resource to manage the accepter's side of a VPC Peering Connection.
## Used when: auto_accept = false (cross-region or cross-account).
##-----------------------------------------------------------------------------
resource "aws_vpc_peering_connection_accepter" "peer" {
  count                     = var.enable_peering && var.auto_accept == false ? 1 : 0
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.region[0].id
  auto_accept               = true

  tags = merge(
    module.labels.tags,
    {
      "Name" = local.peering_name
    }
  )
}

##-----------------------------------------------------------------------------
## Peering connection options (DNS resolution) for the requester side.
## Used when: auto_accept = false (cross-region or cross-account). Options can
## only be set once the connection is active, so this waits for the accepter.
##-----------------------------------------------------------------------------
resource "aws_vpc_peering_connection_options" "requester" {
  count                     = var.enable_peering && var.auto_accept == false ? 1 : 0
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer[0].id

  requester {
    allow_remote_vpc_dns_resolution = var.requestor_allow_remote_vpc_dns_resolution
  }
}

##-----------------------------------------------------------------------------
## Peering connection options (DNS resolution) for the accepter side.
## Used when: auto_accept = false (cross-region or cross-account).
##-----------------------------------------------------------------------------
resource "aws_vpc_peering_connection_options" "accepter" {
  count                     = var.enable_peering && var.auto_accept == false ? 1 : 0
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer[0].id

  accepter {
    allow_remote_vpc_dns_resolution = var.acceptor_allow_remote_vpc_dns_resolution
  }
}

##-----------------------------------------------------------------------------
## provides details about a requestor Route.
## Used when: auto_accept = true (same account, same region).
##-----------------------------------------------------------------------------
resource "aws_route" "requestor" {
  count                     = var.auto_accept ? local.requestor_route_count : 0
  route_table_id            = local.requestor_route_table_ids[floor(count.index / length(local.acceptor_cidr_blocks))]
  destination_cidr_block    = local.acceptor_cidr_blocks[count.index % length(local.acceptor_cidr_blocks)]
  vpc_peering_connection_id = local.peering_connection_id
  depends_on                = [aws_vpc_peering_connection.default]
}

##-----------------------------------------------------------------------------
## provides details about a requestor-region Route.
## Used when: auto_accept = false (cross-region or cross-account).
##-----------------------------------------------------------------------------
resource "aws_route" "requestor-region" {
  count                     = var.auto_accept == false ? local.requestor_route_count : 0
  route_table_id            = local.requestor_route_table_ids[floor(count.index / length(local.acceptor_cidr_blocks))]
  destination_cidr_block    = local.acceptor_cidr_blocks[count.index % length(local.acceptor_cidr_blocks)]
  vpc_peering_connection_id = local.peering_connection_id
  depends_on                = [aws_vpc_peering_connection.region, aws_vpc_peering_connection_accepter.peer]
}

##-----------------------------------------------------------------------------
## provides details about a acceptor Route.
## Used when: auto_accept = true (same account, same region).
##-----------------------------------------------------------------------------
resource "aws_route" "acceptor" {
  count                     = var.auto_accept ? local.acceptor_route_count : 0
  route_table_id            = local.acceptor_route_table_ids[floor(count.index / length(local.requestor_cidr_blocks))]
  destination_cidr_block    = local.requestor_cidr_blocks[count.index % length(local.requestor_cidr_blocks)]
  vpc_peering_connection_id = local.peering_connection_id
  depends_on                = [aws_vpc_peering_connection.default]
}

##-----------------------------------------------------------------------------
## provides details about a acceptor-region Route.
## Used when: auto_accept = false (cross-region or cross-account).
##-----------------------------------------------------------------------------
resource "aws_route" "acceptor-region" {
  count                     = var.auto_accept == false ? local.acceptor_route_count : 0
  provider                  = aws.peer
  route_table_id            = local.acceptor_route_table_ids[floor(count.index / length(local.requestor_cidr_blocks))]
  destination_cidr_block    = local.requestor_cidr_blocks[count.index % length(local.requestor_cidr_blocks)]
  vpc_peering_connection_id = local.peering_connection_id
  depends_on                = [aws_vpc_peering_connection.region, aws_vpc_peering_connection_accepter.peer]
}

provider "aws" {
  alias  = "peer"
  region = local.accept_region
  assume_role {
    role_arn = var.acceptor_role_arn
  }
}

##-----------------------------------------------------------------------------
## Provides a resource to manage a VPC peering connection.
## Used when: auto_accept = false (cross-region or cross-account).
## peer_owner_id uses var.peer_owner_id if provided (cross-account),
## otherwise falls back to current account ID (same-account cross-region).
##-----------------------------------------------------------------------------
resource "aws_vpc_peering_connection" "region" {
  count = var.enable_peering && var.auto_accept == false ? 1 : 0

  vpc_id        = var.requestor_vpc_id
  peer_vpc_id   = var.acceptor_vpc_id
  auto_accept   = var.auto_accept
  peer_region   = local.accept_region
  peer_owner_id = local.peer_owner_id

  tags = merge(
    module.labels.tags,
    {
      "Name" = local.peering_name
    }
  )
}
