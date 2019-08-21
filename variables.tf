variable "vpc_peering" {
  default     = "true"
  description = "Set to false to prevent the module from creating or accessing any resources"
}

variable "requestor_vpc_id" {
  type        = "string"
  description = "Requestor VPC ID"
}

variable "acceptor_vpc_id" {
  type        = "string"
  description = "Acceptor VPC ID"
}

variable "auto_accept" {
  default     = "true"
  description = "Automatically accept the peering (both VPCs need to be in the same AWS account)"
}

variable "acceptor_allow_remote_vpc_dns_resolution" {
  default     = "true"
  description = "Allow acceptor VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requestor VPC"
}

variable "requestor_allow_remote_vpc_dns_resolution" {
  default     = "true"
  description = "Allow requestor VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the acceptor VPC"
}

variable "application" {
  type        = "string"
  description = "Application (e.g. `cp` or `clouddrove`)"
}

variable "environment" {
  type        = "string"
  description = "Environment (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  description = "Name  (e.g. `app` or `cluster`)"
  type        = "string"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}
