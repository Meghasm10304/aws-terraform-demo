provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

# CloudWatch Log Group (already imported)
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/ec2/app"
  retention_in_days = 7
}

# CloudTrail Bucket (new, dedicated for logs)
resource "aws_s3_bucket" "cloudtrail" {
  bucket = "meghana-cloudtrail-logs-2026"   # must be globally unique
}

# CloudTrail (already imported, now points to new bucket)
resource "aws_cloudtrail" "main" {
  name                          = "meghana-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
}

# CloudTrail Bucket Policy
resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Sid": "AWSCloudTrailAclCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}"
    }
  ]
}
POLICY
}

# IAM Role for Flow Logs
resource "aws_iam_role" "flow_logs_role" {
  name = "flow-logs-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
}

# IAM Role Policy for Flow Logs
resource "aws_iam_role_policy" "flow_logs_policy" {
  role = aws_iam_role.flow_logs_role.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

# VPC Flow Logs
resource "aws_flow_log" "vpc" {
  vpc_id               = var.vpc_id
  log_destination      = aws_cloudwatch_log_group.app_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  iam_role_arn         = aws_iam_role.flow_logs_role.arn
}

# WAF WebACL
resource "aws_wafv2_web_acl" "main" {
  name        = "meghana-waf"
  description = "WAF for ALB"
  scope       = "REGIONAL"
  region      = "us-east-1"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSCommonRules"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "aws-common-rules"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "meghana-waf-metric"
    sampled_requests_enabled   = true
  }
}
