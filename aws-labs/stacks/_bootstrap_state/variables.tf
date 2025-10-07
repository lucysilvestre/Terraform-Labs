variable "aws_region" {
  description = "AWS region for the state backend (keep same across envs if possible)"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name: dev | staging | prod"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for the S3 state bucket names (must be globally unique-friendly)"
  type        = string
  default     = "pilu-lab"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "aws_profile" {
  description = "AWS CLI profile name to use"
  type        = string
}