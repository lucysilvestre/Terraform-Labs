# Bootstrap Module — Remote State Infrastructure

This module creates the infrastructure required to store Terraform remote state per environment:

- **S3 Bucket** (versioned, encrypted, no public access)
- **DynamoDB Table** (for state locking, optional)
- Run per environment: **dev**, **staging**, **prod**

---

## Structure

_bootstrap_state/
├─ main.tf
├─ providers.tf
├─ variables.tf
├─ outputs.tf
├─ dev.tfvars
├─ staging.tfvars
└─ prod.tfvars
---

## Requirements

- Terraform `>= 1.5.0`  
- AWS CLI with profile configured  
- Permissions to create S3 and DynamoDB  
- (Optional) `jq` for cleaning versioned buckets  

---

## Variables (`.tfvars`)

Create one `.tfvars` file per environment (`dev.tfvars`, `staging.tfvars`, `prod.tfvars`) and set values such as:

aws_region    = "us-east-1"
aws_profile   = "dev-sso"
environment   = "dev"
bucket_prefix = "xxxxxxxxx"
tags = { Owner = "xxxxzu" }

## How to Run (one environment at a time)
From _bootstrap_state:

### 0) Ensure the correct AWS profile
export AWS_PROFILE=dev-sso    # or default
aws sts get-caller-identity   # check the Account

### 1) Initialize
terraform init

### 2) DEV
terraform workspace new dev || terraform workspace select dev
terraform plan  -var-file=dev.tfvars -out=tfplan-dev
terraform apply tfplan-dev
terraform output
state_bucket_name = "...-dev-tf-state"
lock_table_name   = "...-dev-tf-locks"

### 3) STAGING
terraform workspace new staging || terraform workspace select staging
terraform plan  -var-file=staging.tfvars -out=tfplan-staging
terraform apply tfplan-staging

### 4) PROD
terraform workspace new prod || terraform workspace select prod
terraform plan  -var-file=prod.tfvars -out=tfplan-prod
terraform apply tfplan-prod

## Check created buckets:

aws s3api list-buckets --query 'Buckets[].Name' --output text
should list: <prefix>-dev-tf-state <prefix>-staging-tf-state <prefix>-prod-tf-state

## Using in Stacks:
Each stack (e.g., ec2/) needs a backend.hcl per environment:

bucket       = "xxxx-dev-tf-state"
key          = "ec2/terraform.tfstate"
region       = "us-east-1"
encrypt      = true
use_lockfile = true

If you prefer DynamoDB locking:
dynamodb_table = "xxxxx-dev-tf-locks"

## Initialize with:
terraform init -reconfigure -backend-config=environments/dev/backend.hcl

## Destroying:
	1.	Destroy stacks first (EC2, ECS, etc.)
	2.	Empty versioned buckets (required by S3)
	3.	Destroy the bootstrap in the workspace

### Empty a bucket via CLI (example for DEV):

export B="pilu-lab-123456789012-dev-tf-state"
aws s3api list-object-versions --bucket "$B" \
  --query 'Versions[].{Key:Key,VersionId:VersionId}' --output json > /tmp/versions.json || true
aws s3api delete-objects --bucket "$B" --delete file:///tmp/versions.json || true
aws s3api list-object-versions --bucket "$B" \
  --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' --output json > /tmp/markers.json || true
aws s3api delete-objects --bucket "$B" --delete file:///tmp/markers.json || true

### Destroy by workspace:

terraform workspace select dev
terraform destroy -var-file=dev.tfvars

terraform workspace select staging
terraform destroy -var-file=staging.tfvars

terraform workspace select prod
terraform destroy -var-file=prod.tfvars

## Troubleshooting
BucketAlreadyExists → adjust bucket_prefix (add Account ID to make it unique)
BucketNotEmpty → empty versions and delete markers before destroy
Saved plan is stale → state changed between plan and apply

rm -f tfplan-*
terraform plan  -var-file=<env>.tfvars -out=tfplan-<env>
terraform apply tfplan-<env>

CLI and Terraform profiles differ
aws sts get-caller-identity --query Account --output text
terraform apply -refresh-only -var-file=<env>.tfvars

## Outputs

terraform output
state_bucket_name = "<prefix>-<env>-tf-state"
lock_table_name   = "<prefix>-<env>-tf-locks"
