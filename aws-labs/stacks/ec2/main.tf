# stacks/ec2/main.tf
# EC2 stack — calls the reusable module and wires inputs/outputs.

# Region-aware latest Amazon Linux 2023 (x86_64) from SSM Parameter Store.
# If var.ami_id is not provided in tfvars, we fall back to this dynamic AMI.
data "aws_ssm_parameter" "al2023_x86_64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  common_tags = merge({
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }, var.tags)
}

# Discover default VPC in this region
data "aws_vpc" "default" {
  default = true
}

# Get all subnets of the default VPC (used as a fallback)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Default security group of that default VPC
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

module "ec2_instance" {
  source = "../../modules/ec2_instance"

  name          = "${var.project_name}-${var.environment}"
  ami_id        = coalesce(var.ami_id, data.aws_ssm_parameter.al2023_x86_64.value)
  instance_type = var.instance_type

  # If you pass subnet_id in tfvars we use it; otherwise fallback to first default-VPC subnet
  subnet_id = coalesce(var.subnet_id, try(data.aws_subnets.default.ids[0], null))

  # If you pass SGs in tfvars we use them; otherwise fallback to the default SG
  security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : [data.aws_security_group.default.id]

  associate_public_ip = var.associate_public_ip
  key_name            = var.key_name
  user_data           = null

  tags = local.common_tags
}

# Useful outputs
output "ec2_instance_id" {
  description = "EC2 instance ID created by this stack."
  value       = module.ec2_instance.instance_id
}

output "ec2_public_ip" {
  description = "Public IP (null if not assigned)."
  value       = module.ec2_instance.public_ip
}

# debug (opcional): ver a conta que o provider está usando
data "aws_caller_identity" "who" {}

output "tf_account_id" {
  value = data.aws_caller_identity.who.account_id
}