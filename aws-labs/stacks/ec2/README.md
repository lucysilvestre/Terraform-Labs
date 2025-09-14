# EC2 Stack — Terraform Labs

This stack provisions an **EC2 instance** by calling the reusable `ec2_instance` module.  
It supports multiple environments (dev, staging, prod) with separate backends and variable files.

---

## Structure

```
stacks/ec2/
├─ main.tf              # Calls the ec2_instance module
├─ variables.tf         # Stack-level variables (region, profile, env, etc.)
├─ outputs.tf           # Outputs forwarded from the module
├─ providers.tf         # AWS provider configuration
├─ environments/
│   ├─ dev/
│   │   ├─ backend.hcl
│   │   └─ terraform.tfvars
│   ├─ staging/
│   │   ├─ backend.hcl
│   │   └─ terraform.tfvars
│   └─ prod/
│       ├─ backend.hcl
│       └─ terraform.tfvars
```

---

## Requirements

- Terraform `>= 1.5.0`  
- AWS CLI with profiles configured  
- Remote state S3 buckets and DynamoDB tables already created via `_bootstrap_state`  

---

## Backend Example

`environments/dev/backend.hcl`:

```hcl
bucket       = "<prefix>-<account_id>-dev-tf-state"
key          = "ec2/terraform.tfstate"
region       = "us-east-1"
encrypt      = true
use_lockfile = true
# Or use DynamoDB instead:
# dynamodb_table = "<prefix>-<account_id>-dev-tf-locks"
```

---

## Variables Example

`environments/dev/terraform.tfvars`:

```hcl
aws_region        = "us-east-1"
aws_profile       = "dev-profile"
environment       = "dev"

project_name      = "ec2-lab"
instance_type     = "t2.micro"
ami_id            = "ami-xxxxxxxxxxxxxxx"

associate_public_ip = true
key_name            = "my-keypair"
tags = {
  Owner = "DemoUser"
  Env   = "dev"
}
```

---

## How to Deploy

From `stacks/ec2/`:

```bash
# Initialize backend for DEV
terraform init -reconfigure -backend-config=environments/dev/backend.hcl

# Plan and Apply for DEV
terraform plan -var-file=environments/dev/terraform.tfvars -out=tfplan-dev
terraform apply tfplan-dev

# Show outputs
terraform output
```

Repeat with `staging/terraform.tfvars` and `prod/terraform.tfvars` for other environments.

---

## Destroying

To destroy the EC2 instance in an environment:

```bash
terraform init -reconfigure -backend-config=environments/dev/backend.hcl
terraform destroy -var-file=environments/dev/terraform.tfvars
```

---

## Outputs

- `ec2_instance_id` — Instance ID from the module  
- `ec2_public_ip` — Public IP (if assigned)  

---

## Troubleshooting

- **InvalidSubnetID.NotFound** → check if the subnet exists or adjust `subnet_id`  
- **AccessDenied** → ensure the AWS profile has EC2 permissions  
- **Stale plan** → re-run `terraform plan` + `terraform apply`  
- **Wrong account/profile** → compare Terraform vs CLI:
  ```bash
  aws sts get-caller-identity --query Account --output text
  terraform apply -refresh-only -var-file=environments/dev/terraform.tfvars
  ```
  Ensure `aws_profile` matches `AWS_PROFILE`
