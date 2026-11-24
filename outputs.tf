#Module : VPC PEERING
#Description : Terraform module to connect two VPC's on AWS.

output "connection_id" {
  value       = local.peering_connection_id
  description = "VPC peering connection ID."
}

output "accept_status" {
  value       = var.auto_accept ? join("", aws_vpc_peering_connection.default[*].accept_status) : join("", aws_vpc_peering_connection_accepter.peer[*].accept_status)
  description = "The status of the VPC peering connection request."
}

output "requestor_vpc_cidr_blocks" {
  value       = local.requestor_cidr_blocks
  description = "All CIDR blocks associated with the requestor VPC."
}

output "acceptor_vpc_cidr_blocks" {
  value       = local.acceptor_cidr_blocks
  description = "All CIDR blocks associated with the acceptor VPC."
}

output "requestor_route_table_ids" {
  value       = var.enable_peering && var.create_requestor_routes ? local.requestor_route_table_ids : []
  description = "Requestor route table IDs that received routes to the acceptor VPC."
}

output "acceptor_route_table_ids" {
  value       = var.enable_peering && var.create_acceptor_routes ? local.acceptor_route_table_ids : []
  description = "Acceptor route table IDs that received routes to the requestor VPC."
}

output "requestor_route_ids" {
  value       = concat(aws_route.requestor[*].id, aws_route.requestor-region[*].id)
  description = "IDs of the routes created in the requestor route tables."
}

output "acceptor_route_ids" {
  value       = concat(aws_route.acceptor[*].id, aws_route.acceptor-region[*].id)
  description = "IDs of the routes created in the acceptor route tables."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}
