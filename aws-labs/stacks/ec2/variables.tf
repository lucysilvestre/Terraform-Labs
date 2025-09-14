// EC2 stack — inputs expected from environments/<env>/terraform.tfvars

variable "aws_region" {
  description = "AWS region (e.g., us-east-1)"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile (must match your terminal's AWS_PROFILE)"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Logical project name used in tags and naming"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI to use (optional). If null, stack falls back to SSM latest AL2023 x86_64"
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Associate a public IP with the instance"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "EC2 key pair name for SSH (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to merge with defaults"
  type        = map(string)
  default     = {}
}
variable "security_group_ids" {
  description = "Security groups to attach (if empty, use default SG)"
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  description = "Subnet to launch into (optional; if null, fallback tries default VPC)"
  type        = string
  default     = null
}