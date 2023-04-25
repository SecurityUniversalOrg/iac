provider "aws" {
  region = "us-west-2"
}

locals {
  waf_acl_name          = "example-waf-acl"
  s3_bucket_name        = "example-waf-logs"
  firehose_stream_name  = "example-waf-logs-firehose"
  splunk_host           = "your.splunk.instance.com"
  splunk_token          = "your-splunk-hec-token"
  splunk_port           = 8088
  splunk_ssl_validation = true
}

resource "aws_wafv2_web_acl" "example" {
  name        = local.waf_acl_name
  description = "Example WAFv2 Web ACL"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.waf_acl_name
    sampled_requests_enabled   = true
  }
}

resource "aws_s3_bucket" "example" {
  bucket = local.s3_bucket_name
}

resource "aws_kinesis_firehose_delivery_stream" "example" {
  name        = local.firehose_stream_name
  destination = "splunk"

  s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.example.arn
    buffer_size        = 5
    buffer_interval    = 300
    compression_format = "UNCOMPRESSED"
  }

  splunk_configuration {
    hec_endpoint               = "https://${local.splunk_host}:${local.splunk_port}"
    hec_token                  = local.splunk_token
    hec_acknowledgment_timeout = 600
    retry_duration             = 300

    s3_backup_mode = "AllEvents"

    processing_configuration {
      enabled = true

      processors {
        type = "RecordDeAggregation"
      }
    }
  }
}

resource "aws_iam_role" "firehose_role" {
  name = "firehose_delivery_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "firehose_policy" {
  name   = "firehose_delivery_policy"
  role   = aws_iam_role.firehose_role.id
  policy = data.aws_iam_policy_document.firehose_policy.json
}

data "aws_iam_policy_document" "firehose_policy" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.example.arn,
      "${aws_s3_bucket.example.arn}/*",
    ]
  }

  statement {
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "example" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "example-subnet"
  }
}

resource "aws_security_group" "example" {
  name        = "example"
  description = "Example security group for ALB"
  vpc_id      = aws_vpc.example.id
}

resource "aws_lb" "example" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.example.id]
  subnets            = [aws_subnet.example.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.example.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-west-2:ACCOUNT_ID:certificate/CERTIFICATE_ID"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}

resource "aws_wafv2_web_acl_association" "example" {
  web_acl_arn = aws_wafv2_web_acl.example.arn
  resource_arn = aws_lb_listener.https.arn
}

