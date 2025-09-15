# ECS Fargate Stack (Minimal)

Creates a **public ECS Fargate service** (nginx) using the **default VPC**.  
State is stored in **S3 per environment** using a **separate key** for this stack.

> This stack reuses the backend buckets created earlier (e.g., from EC2 labs).  
> **Only the `key` changes**: `ecs/<env>/terraform.tfstate`.

## Structure

```
aws-labs/
├─ modules/
│  └─ ecs_fargate_service/   # reusable module (cluster + task + service)
└─ stacks/
   └─ ecs/
      ├─ main.tf
      ├─ providers.tf
      ├─ variables.tf
      ├─ outputs.tf
      └─ environments/
         ├─ dev/
         │  ├─ backend.hcl
         │  └─ terraform.tfvars
         ├─ staging/
         │  ├─ backend.hcl
         │  └─ terraform.tfvars
         └─ prod/
            ├─ backend.hcl
            └─ terraform.tfvars
```

## Requirements

- Terraform `>= 1.5`
- AWS CLI configured (SSO or keys)
- Existing **S3 state buckets** per env (e.g., `my-labs-<account_id>-dev-tf-state`)
- Permissions to create ECS, IAM roles, and CloudWatch logs

## Backend (per environment)

Example: `environments/dev/backend.hcl`
```hcl
bucket       = "my-labs-<account_id>-dev-tf-state"
key          = "ecs/dev/terraform.tfstate"
region       = "us-east-1"
use_lockfile = true
profile      = "dev-sso"
```

> For staging/prod, change `bucket`, `key`, and `profile` accordingly:
> - `my-labs-<account_id>-staging-tf-state`, key `ecs/staging/terraform.tfstate`, profile `staging-sso`
> - `my-labs-<account_id>-prod-tf-state`,    key `ecs/prod/terraform.tfstate`,    profile `prod-sso`

## Variables (per environment)

Example: `environments/dev/terraform.tfvars`
```hcl
aws_region  = "us-east-1"
aws_profile = "dev-sso"
environment = "dev"

project_name    = "ecs-lab"
container_image = "public.ecr.aws/nginx/nginx:latest"
container_port  = 80

# Optional explicit networking (otherwise: default VPC + default SG)
# subnet_ids         = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"]
# security_group_ids = ["sg-zzzzzzzz"]

tags = {
  Owner = "YourName"
  Env   = "dev"
}
```

> Do **not** commit real `terraform.tfvars` or `backend.hcl`. They should be ignored by `.gitignore`.

## How to Run

### DEV
```bash
cd aws-labs/stacks/ecs
export AWS_PROFILE=dev-sso
export AWS_SDK_LOAD_CONFIG=1

terraform init -reconfigure -backend-config=environments/dev/backend.hcl
terraform plan  -var-file=environments/dev/terraform.tfvars -out=tfplan-dev
terraform apply tfplan-dev

terraform output
# cluster_name, service_name, task_family, log_group_name, tf_account_id
```

### STAGING
```bash
export AWS_PROFILE=staging-sso
terraform init -reconfigure -backend-config=environments/staging/backend.hcl
terraform plan  -var-file=environments/staging/terraform.tfvars -out=tfplan-staging
terraform apply tfplan-staging
```

### PROD
```bash
export AWS_PROFILE=prod-sso
terraform init -reconfigure -backend-config=environments/prod/backend.hcl
terraform plan  -var-file=environments/prod/terraform.tfvars -out=tfplan-prod
terraform apply tfplan-prod
```

## Update container image

Change `container_image` in your env `terraform.tfvars`, then:
```bash
terraform plan  -var-file=environments/<env>/terraform.tfvars -out=tfplan-<env>
terraform apply tfplan-<env>
```
> The service uses `ignore_changes = [task_definition]`, so Terraform will register a new task definition and update the service in place.

## Destroy (per environment)

```bash
# DEV
export AWS_PROFILE=dev-sso
terraform destroy -var-file=environments/dev/terraform.tfvars

# STAGING
export AWS_PROFILE=staging-sso
terraform destroy -var-file=environments/staging/terraform.tfvars

# PROD
export AWS_PROFILE=prod-sso
terraform destroy -var-file=environments/prod/terraform.tfvars
```

## Troubleshooting

- **Backend prompting for bucket**  
  Ensure you used:  
  `terraform init -reconfigure -backend-config=environments/<env>/backend.hcl`  
  and that `profile/bucket/key/region` in the file are correct.

- **SSO expired**  
  `aws sso login --profile <env>-sso` and re-run `init`.

- **State mixing across envs**  
  Each env must have its own **bucket** and **key**. If a resource is “linked” to the wrong env, in the correct env run:
  ```bash
  terraform state rm module.svc.aws_ecs_service.this
  terraform plan  -var-file=environments/<env>/terraform.tfvars -out=tfplan-<env>
  terraform apply tfplan-<env>
  ```

---
