terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.1"
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# S3 bucket with lifecycle policies
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = var.bucket_acl

  lifecycle_rule {
    id      = "images"
    enabled = true

    prefix = "images/"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }

  lifecycle_rule {
    id      = "logs"
    prefix  = "logs/"
    enabled = true

    expiration {
      days = 90
    }
  }
}
