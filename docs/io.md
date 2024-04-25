## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| accept\_region | The region of the accepter VPC of the VPC Peering Connection. | `string` | `""` | no |
| acceptor\_allow\_remote\_vpc\_dns\_resolution | Allow acceptor VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requestor VPC. | `bool` | `true` | no |
| acceptor\_vpc\_id | Acceptor VPC ID. | `string` | n/a | yes |
| attributes | Additional attributes (e.g. `1`). | `list(any)` | `[]` | no |
| auto\_accept | Automatically accept the peering (both VPCs need to be in the same AWS account). | `bool` | `true` | no |
| enable\_peering | Set to false to prevent the module from creating or accessing any resources. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| label\_order | label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| managedby | ManagedBy, eg 'CloudDrove'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-vpc-peering"` | no |
| requestor\_allow\_remote\_vpc\_dns\_resolution | Allow requestor VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the acceptor VPC. | `bool` | `true` | no |
| requestor\_vpc\_id | Requestor VPC ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| accept\_status | The status of the VPC peering connection request. |
| connection\_id | VPC peering connection ID. |
| tags | A mapping of tags to assign to the resource. |

