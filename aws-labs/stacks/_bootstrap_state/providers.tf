terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }

  # IMPORTANT: Bootstrap uses LOCAL state on first run.
  # After S3/DynamoDB exist, other stacks will use remote backend via backend.hcl.
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}