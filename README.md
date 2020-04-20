## Usage

Creates an AWS WAF Regional Web ACL for use with AWS API Gateway REST API.  This is a regional resource, so you must create the WAF in the same region as your API Gateway.

```hcl
module "cloudfront_waf" {
  source = "dod-iac/api-gateway-waf/aws"

  name = format("app-%s-api-%s", var.application, var.environment)

  metric_name = format("app%sApi%s", title(var.application), title(var.environment))

  allowed_hosts = [format("%s.execute-api.%s.amazonaws.com", aws_api_gateway_rest_api.main.id, data.aws_region.current.name)]

  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

You can then associate the WAF with a REST API stage using the `aws_wafregional_web_acl_association` terraform resource.

If you are not using terraform to manage API Gateway stages, then you can associate using the AWS CLI using the command `aws waf-regional associate-web-acl --web-acl-id WEB_ACL_ID --resource-arn RESOURCE_ARN`.

## Terraform Version

Terraform 0.12. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.

Terraform 0.11 is not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.55.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.55.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_hosts | List of allowed values for the host header. | `list(string)` | n/a | yes |
| aws\_wafregional\_byte\_match\_set\_allowed\_hosts\_name | The name of the aws\_wafregional\_byte\_match\_set used by the rule used for filtering by host header.  Defaults to "[name]-allowed-hosts". | `string` | `""` | no |
| aws\_wafregional\_rule\_allowed\_hosts\_metric\_name | The metric name of the rule used for filtering by host header.  Defaults to "[metric\_name]AllowedHosts". | `string` | `""` | no |
| aws\_wafregional\_rule\_allowed\_hosts\_name | The name of the rule used for filtering by host header.  Defaults to "[name]-allowed-hosts". | `string` | `""` | no |
| metric\_name | The name or description for the Amazon CloudWatch metric of this web ACL. | `string` | n/a | yes |
| name | The name or description of the web ACL. | `string` | n/a | yes |
| tags | A mapping of tags to assign to the WAF Web ACL Resource and WAF Rules. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| web\_acl\_id | The ID of the WAF WebACL. |

