/**
 * ## Usage
 *
 * Creates an AWS WAF Regional Web ACL for use with AWS API Gateway REST API.  This is a regional resource, so you must create the WAF in the same region as your API Gateway.
 *
 *
 * ```hcl
 * module "cloudfront_waf" {
 *   source = "dod-iac/api-gateway-waf/aws"
 *
 *   name = format("app-%s-api-%s", var.application, var.environment)
 *
 *   metric_name = format("app%sApi%s", title(var.application), title(var.environment))
 *
 *   allowed_hosts = [format("%s.execute-api.%s.amazonaws.com", aws_api_gateway_rest_api.main.id, data.aws_region.current.name)]
 *
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * You can then associate the WAF with a REST API stage using the `aws_wafregional_web_acl_association` terraform resource.
 *
 * If you are not using terraform to manage API Gateway stages, then you can associate using the AWS CLI using the command `aws waf-regional associate-web-acl --web-acl-id WEB_ACL_ID --resource-arn RESOURCE_ARN`.
 *
 * ## Terraform Version
 *
 * Terraform 0.12. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.
 *
 * Terraform 0.11 is not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

# The aws_waf_byte_match_set used by the rule used for filtering by host header.
resource "aws_wafregional_byte_match_set" "allowed_hosts" {
  name = length(var.aws_wafregional_byte_match_set_allowed_hosts_name) > 0 ? var.aws_wafregional_byte_match_set_allowed_hosts_name : format("%s-allowed-hosts", var.name)

  dynamic "byte_match_tuples" {
    for_each = var.allowed_hosts
    content {
      # Even though the AWS Console web UI suggests a capitalized "host" data,
      # the data should be lower case as the AWS API will silently lowercase anyway.
      field_to_match {
        type = "HEADER"
        data = "host"
      }

      target_string = byte_match_tuples.value

      # See ByteMatchTuple for possible variable options.
      # See https://docs.aws.amazon.com/waf/latest/APIReference/API_ByteMatchTuple.html#WAF-Type-ByteMatchTuple-PositionalConstraint
      positional_constraint = "EXACTLY"

      # Use COMPRESS_WHITE_SPACE to prevent sneaking around regex filter with
      # extra or non-standard whitespace
      # See https://docs.aws.amazon.com/sdk-for-go/api/service/waf/#RegexMatchTuple
      text_transformation = "COMPRESS_WHITE_SPACE"
    }
  }
}

# The rule used for filtering by host header.
resource "aws_wafregional_rule" "allowed_hosts" {
  name        = length(var.aws_wafregional_rule_allowed_hosts_name) > 0 ? var.aws_wafregional_rule_allowed_hosts_name : format("%s-allowed-hosts", var.name)
  metric_name = length(var.aws_wafregional_rule_allowed_hosts_metric_name) > 0 ? var.aws_wafregional_rule_allowed_hosts_metric_name : format("%sAllowedHosts", var.metric_name)

  predicate {
    type    = "ByteMatch"
    data_id = aws_wafregional_byte_match_set.allowed_hosts.id
    negated = true
  }

  tags = var.tags
}

resource "aws_wafregional_web_acl" "main" {
  depends_on = [
    aws_wafregional_rule.allowed_hosts,
  ]

  name        = var.name
  metric_name = var.metric_name

  default_action {
    type = "ALLOW"
  }

  rule {
    action {
      type = "BLOCK"
    }
    priority = 1
    rule_id  = aws_wafregional_rule.allowed_hosts.id
    type     = "REGULAR"
  }

  tags = var.tags
}
