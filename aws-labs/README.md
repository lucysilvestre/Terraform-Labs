# AWS Labs ECS — dev/staging/prod

This repository contains hands-on labs for deploying AWS resources using **Terraform**.  
Each service (ECS) is managed as a separate stack, with reusable modules and isolated environments (dev, staging, prod).

## How to Use (ex.: EC2)

cd stacks/ec2/environments/dev
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
# terraform destroy

Diagram:
+-------------------+
|   _bootstrap_state|
|  (S3 + DynamoDB)  |
+---------+---------+
          |
          v
+---------+---------+
|    stacks/ec2     |
| (Calls module,    |
|  uses tfvars,     |
|  backend.hcl)     |
+---------+---------+
          |
          v
+---------+---------+
| modules/ec2_instance
| (Reusable EC2     |
|  resource)        |
+---------+---------+
          |
          v
+---------+---------+
|    AWS Cloud      |
|   (EC2 Instance)  |
+-------------------+