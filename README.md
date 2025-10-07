# Terraform Labs

This repository contains a collection of Terraform labs designed for learning and practicing Infrastructure as Code (IaC) concepts in AWS.  
Each lab is structured with **reusable modules** and **environment-specific stacks** (dev, staging, prod), following best practices such as remote state, workspaces, and environment separation.

---

## Structure

```plaintext
Terraform-Labs/
├─ aws-labs/
│  ├─ modules/                 # Reusable modules
│  │   ├─ ec2_instance/        # Module to deploy EC2 instances
│  │   └─ ecs_fargate_service/ # Module to deploy ECS services (Fargate)
│  │
│  └─ stacks/                  # Stacks that call the modules
│      ├─ _bootstrap_state/    # Creates S3 + DynamoDB for remote state
│      ├─ ec2/                 # EC2 lab stack
│      └─ ecs/                 # ECS lab stack
│
└─ README.md                   # This file
```

---

## Available Labs

- **_bootstrap_state**  
  Creates the S3 buckets and DynamoDB tables used for Terraform remote state management.

- **EC2 Stack**  
  Provisions EC2 instances using the reusable `ec2_instance` module.  
  Each environment (dev/staging/prod) uses its own remote state and variables.

- **ECS Stack**  
  Deploys a basic ECS Fargate service using the reusable `ecs_fargate_service` module.  
  Useful for practicing container orchestration in AWS.

---

## Requirements

- Terraform `>= 1.5.0`
- AWS CLI configured with profiles (`aws configure sso` or `aws configure`)
- IAM permissions to create resources: S3, DynamoDB, EC2, ECS, IAM roles, etc.

---

## How to Use

1. **Bootstrap remote state**  
   Go to `aws-labs/stacks/_bootstrap_state` and follow the README there to create remote state resources.

2. **Deploy a stack**  
   Example (EC2 in `dev`):
   ```bash
   cd aws-labs/stacks/ec2
   terraform init -reconfigure -backend-config=environments/dev/backend.hcl
   terraform plan -var-file=environments/dev/terraform.tfvars -out=tfplan-dev
   terraform apply tfplan-dev
   ```

3. **Check resources**  
   After apply, Terraform outputs the instance ID, public IP, or ECS service details.

---

## Notes

- **Sensitive values** (like `tfvars` and `backend.hcl`) are intentionally excluded via `.gitignore`.  
- Each environment keeps its own **remote state** in S3 to prevent overlap.  
- The repository is for **learning/labs only** — adapt before using in production.

---

## Next Steps

- Add more modules 
