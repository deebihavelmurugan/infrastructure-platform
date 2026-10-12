terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  name_prefix = "${var.team_name}-${var.environment}"
}

# 1. Dedicated IAM Role per Team/Environment
resource "aws_iam_role" "workload" {
  name = "platform-workload-${local.name_prefix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Team        = var.team_name
    Environment = var.environment
    ManagedBy   = "PlatformEngineering"
  }
}

# 2. Dynamic S3 Buckets with Automated Guardrails
resource "aws_s3_bucket" "bucket" {
  for_each = { for b in var.buckets : b.name => b }

  bucket = "company-${var.team_name}-${var.environment}-${each.value.name}"

  tags = {
    Team        = var.team_name
    Environment = var.environment
    IsPublic    = each.value.public ? "true" : "false"
  }
}

# Enforce Default Server-Side Encryption (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  for_each = aws_s3_bucket.bucket
  bucket   = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enforce Granular S3 Public Access Block Controls
resource "aws_s3_bucket_public_access_block" "block_access" {
  for_each = aws_s3_bucket.bucket

  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = each.value.public ? false : true
  ignore_public_acls      = true
  restrict_public_buckets = each.value.public ? false : true
}

# Public Bucket Policy Attached ONLY When Explicitly Requested
resource "aws_s3_bucket_policy" "public_policy" {
  for_each = { for k, v in var.buckets : k => v if v.public == true }

  bucket = aws_s3_bucket.bucket[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.bucket[each.key].arn}/*"
      }
    ]
  })
}

# 3. Least-Privilege IAM Policy Scoped Strictly to Team's Own Buckets
resource "aws_iam_role_policy" "bucket_access" {
  name = "bucket-access-${local.name_prefix}"
  role = aws_iam_role.workload.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = flatten([
          for b in aws_s3_bucket.bucket : [
            b.arn,
            "${b.arn}/*"
          ]
        ])
      }
    ]
  })
}
