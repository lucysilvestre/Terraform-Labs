locals {
  name = "${var.project_name}-${var.environment}"
  tags = merge({
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }, var.tags)
}

module "svc" {
  source = "../../modules/ecs_fargate_service"

  name             = local.name
  aws_region       = var.aws_region
  container_name   = "web"
  container_image  = var.container_image
  container_port   = var.container_port
  desired_count    = 1
  cpu              = "256"
  memory           = "512"
  cpu_architecture = "X86_64"

  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
  tags               = local.tags
}

data "aws_caller_identity" "who" {}

output "tf_account_id" { value = data.aws_caller_identity.who.account_id }
output "cluster_name" { value = module.svc.cluster_name }
output "service_name" { value = module.svc.service_name }
output "task_family" { value = module.svc.task_family }
output "log_group_name" { value = module.svc.log_group_name }