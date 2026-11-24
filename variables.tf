#Module : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name (e.g. `app` or `cluster`)."
}

variable "attributes" {
  type        = list(any)
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-aws-vpc-peering"
  description = "Terraform current module repo"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "label order, e.g. `name`,`application`."
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources (e.g. `{ BusinessUnit = \"XYZ\" }`)."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'."
}

#Module : VPC PEERING
#Description : Terraform vpc peering module variables.
variable "enable_peering" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating or accessing any resources."
}

variable "requestor_vpc_id" {
  type        = string
  description = "Requestor VPC ID."
}

variable "acceptor_vpc_id" {
  type        = string
  description = "Acceptor VPC ID."
}

variable "auto_accept" {
  type        = bool
  default     = true
  description = "Automatically accept the peering (both VPCs need to be in the same AWS account)."
}

variable "accept_region" {
  type        = string
  default     = ""
  description = "The region of the accepter VPC of the VPC Peering Connection. Required when `auto_accept` is false."

  validation {
    condition     = var.auto_accept || var.accept_region != ""
    error_message = "accept_region must be set when auto_accept is false (cross-region or cross-account peering)."
  }
}

variable "peer_owner_id" {
  type        = string
  default     = ""
  description = "The AWS account ID of the acceptor VPC owner. Leave empty for same-account peering (defaults to current account ID)."
}

variable "acceptor_role_arn" {
  type        = string
  default     = ""
  description = "The ARN of the IAM role to assume in the acceptor account for cross-account VPC peering."
}

variable "acceptor_allow_remote_vpc_dns_resolution" {
  type        = bool
  default     = true
  description = "Allow acceptor VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requestor VPC."
}

variable "requestor_allow_remote_vpc_dns_resolution" {
  type        = bool
  default     = true
  description = "Allow requestor VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the acceptor VPC."
}

variable "requestor_route_table_ids" {
  type        = list(string)
  default     = []
  description = "List of requestor route table IDs to add peering routes to. Leave empty to add routes to every route table in the requestor VPC."
}

variable "acceptor_route_table_ids" {
  type        = list(string)
  default     = []
  description = "List of acceptor route table IDs to add peering routes to. Leave empty to add routes to every route table in the acceptor VPC."
}

variable "create_requestor_routes" {
  type        = bool
  default     = true
  description = "Whether to create routes to the acceptor VPC in the requestor route tables."
}

variable "create_acceptor_routes" {
  type        = bool
  default     = true
  description = "Whether to create routes to the requestor VPC in the acceptor route tables."
}
