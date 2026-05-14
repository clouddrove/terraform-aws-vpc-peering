#Module : VPC PEERING
#Description : Terraform module to connect two VPC's on AWS.

output "connection_id" {
  value       = var.auto_accept ? join("", aws_vpc_peering_connection.default[*].id) : join("", aws_vpc_peering_connection.region[*].id)
  description = "VPC peering connection ID."
}

output "accept_status" {
  value       = var.auto_accept ? join("", aws_vpc_peering_connection.default[*].accept_status) : join("", aws_vpc_peering_connection_accepter.peer[*].accept_status)
  description = "The status of the VPC peering connection request."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}