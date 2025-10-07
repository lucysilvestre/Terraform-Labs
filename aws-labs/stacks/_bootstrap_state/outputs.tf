output "state_bucket_name" {
  description = "S3 bucket to be used as Terraform remote state backend"
  value       = aws_s3_bucket.state.bucket
}

output "lock_table_name" {
  description = "DynamoDB table name for state locking"
  value       = aws_dynamodb_table.locks.name
}