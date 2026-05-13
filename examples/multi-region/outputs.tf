#Module      : VPC PEERING
#Description : Terraform vpc peering module output variables.
output "accept_status" {
  value       = module.vpc-peering.accept_status
  description = "The status of the VPC peering connection request."
}

output "tags" {
  value       = module.vpc-peering.tags
  description = "A mapping of tags to assign to the VPC Peering."
}
