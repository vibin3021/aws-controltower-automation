# Terraform Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Caller Identity
data "aws_caller_identity" "current" {}

# CloudTrail Service Account
data "aws_cloudtrail_service_account" "main" {}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Public Subnet
resource "aws_subnet" "Ass_public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# Private Subnet
resource "aws_subnet" "Ass_private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Security Group
resource "aws_security_group" "Ass_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# S3 Bucket for CloudTrail Logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "landing-zone-cloudtrail-logs"
  force_destroy = true
}

# IAM Policy for CloudTrail Logging
data "aws_iam_policy_document" "allow_cloudtrail_logging" {
  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_cloudtrail_service_account.main.arn]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_cloudtrail_service_account.main.arn]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail_logs.arn]
  }
}

# Attach the Policy to the S3 Bucket
resource "aws_s3_bucket_policy" "allow_cloudtrail_logging" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = data.aws_iam_policy_document.allow_cloudtrail_logging.json
}

# CloudTrail Setup
resource "aws_cloudtrail" "main" {
  name                          = "landing-zone-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
}

# GuardDuty Detector
resource "aws_guardduty_detector" "Ass_guardduty" {
  enable = true
}

