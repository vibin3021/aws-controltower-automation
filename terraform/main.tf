terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

data "aws_caller_identity" "current" {}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_security_group" "allow_basic" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "landing-zone-cloudtrail-logs"
}

resource "aws_cloudtrail" "main" {
  name                       = "landing-zone-cloudtrail"
  s3_bucket_name             = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail      = true
}

resource "aws_guardduty_detector" "guardduty" {
  enable = true
}

resource "aws_instance" "workload_instance" {
  ami           = "ami-04b4f1a9cf54c11d0" 
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_subnet.id

  vpc_security_group_ids = [aws_security_group.allow_basic.id]

  tags = {
    Name = "Workload-Instance"
  }
}
