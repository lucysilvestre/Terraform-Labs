terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS provider — region/profile come from variables (set in tfvars)
provider "aws" {
  region  = var.aws_region  # e.g., "us-east-1"
  profile = var.aws_profile # must match an AWS CLI profile
}