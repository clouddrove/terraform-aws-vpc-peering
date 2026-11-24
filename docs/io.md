## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| accept\_region | The region of the accepter VPC of the VPC Peering Connection. Required when `auto_accept` is false. | `string` | `""` | no |
| acceptor\_allow\_remote\_vpc\_dns\_resolution | Allow acceptor VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requestor VPC. | `bool` | `true` | no |
| acceptor\_role\_arn | The ARN of the IAM role to assume in the acceptor account for cross-account VPC peering. | `string` | `""` | no |
| acceptor\_route\_table\_ids | List of acceptor route table IDs to add peering routes to. Leave empty to add routes to every route table in the acceptor VPC. | `list(string)` | `[]` | no |
| acceptor\_vpc\_id | Acceptor VPC ID. | `string` | n/a | yes |
| attributes | Additional attributes (e.g. `1`). | `list(any)` | `[]` | no |
| auto\_accept | Automatically accept the peering (both VPCs need to be in the same AWS account). | `bool` | `true` | no |
| create\_acceptor\_routes | Whether to create routes to the requestor VPC in the acceptor route tables. | `bool` | `true` | no |
| create\_requestor\_routes | Whether to create routes to the acceptor VPC in the requestor route tables. | `bool` | `true` | no |
| enable\_peering | Set to false to prevent the module from creating or accessing any resources. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| extra\_tags | Additional tags to apply to all resources (e.g. `{ BusinessUnit = "XYZ" }`). | `map(string)` | `{}` | no |
| label\_order | label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| managedby | ManagedBy, eg 'CloudDrove'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| peer\_owner\_id | The AWS account ID of the acceptor VPC owner. Leave empty for same-account peering (defaults to current account ID). | `string` | `""` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-vpc-peering"` | no |
| requestor\_allow\_remote\_vpc\_dns\_resolution | Allow requestor VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the acceptor VPC. | `bool` | `true` | no |
| requestor\_route\_table\_ids | List of requestor route table IDs to add peering routes to. Leave empty to add routes to every route table in the requestor VPC. | `list(string)` | `[]` | no |
| requestor\_vpc\_id | Requestor VPC ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| accept\_status | The status of the VPC peering connection request. |
| acceptor\_route\_ids | IDs of the routes created in the acceptor route tables. |
| acceptor\_route\_table\_ids | Acceptor route table IDs that received routes to the requestor VPC. |
| acceptor\_vpc\_cidr\_blocks | All CIDR blocks associated with the acceptor VPC. |
| connection\_id | VPC peering connection ID. |
| requestor\_route\_ids | IDs of the routes created in the requestor route tables. |
| requestor\_route\_table\_ids | Requestor route table IDs that received routes to the acceptor VPC. |
| requestor\_vpc\_cidr\_blocks | All CIDR blocks associated with the requestor VPC. |
| tags | A mapping of tags to assign to the resource. |
