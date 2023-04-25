provider "aws" {
  region = "us-west-2"
}

resource "aws_wafv2_web_acl" "example" {
  name        = "example-web-acl"
  description = "Example WAFv2 WebACL using OWASP and custom rules"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "aws-managed-owasp-rule"
    priority = 0

    action {
      block {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "aws-managed-owasp-rule"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "custom-rule"
    priority = 1

    action {
      block {}
    }

    statement {
      or_statement {
        statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }
            positional_constraint = "CONTAINS"
            search_string         = "example-bad-string"
            text_transformation {
              priority = 1
              type     = "NONE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "custom-rule"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "example-web-acl"
    sampled_requests_enabled   = false
  }
}
