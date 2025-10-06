locals {
  # Final names per environment (predictable and consistent)
  bucket_name = lower("${var.bucket_prefix}-${var.environment}-tf-state")
  table_name  = lower("${var.bucket_prefix}-${var.environment}-tf-locks")

  common_tags = merge({
    Project     = "aws-labs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }, var.tags)
}

# S3 bucket for remote state
resource "aws_s3_bucket" "state" {
  bucket = local.bucket_name
  tags   = local.common_tags
}

# Best practices for state buckets
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "locks" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.common_tags
}

data "aws_caller_identity" "me" {}
output "tf_account_id" {
  value = data.aws_caller_identity.me.account_id
}

