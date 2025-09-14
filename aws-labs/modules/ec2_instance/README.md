# EC2 Instance Module

This reusable Terraform module provisions a single **EC2 instance** in AWS.  
It is designed to be minimal and explicit, with all inputs provided by the caller (stack).

---

## Structure

```
modules/ec2_instance/
├─ main.tf        # Defines the EC2 resource (aws_instance.this)
├─ variables.tf   # Input variables (AMI, type, subnet, SGs, key, tags, etc.)
└─ outputs.tf     # Outputs (instance_id, public_ip)
```

---

## Inputs

- **name** (string, required) — Name tag for the instance  
- **ami_id** (string, required) — AMI ID to use  
- **instance_type** (string, required) — e.g. `t2.micro`  
- **subnet_id** (string, optional, default `null`) — Subnet where to launch the instance  
- **security_group_ids** (list(string), optional, default `[]`) — Security groups  
- **associate_public_ip** (bool, optional, default `true`) — Assign a public IP  
- **key_name** (string, optional, default `null`) — Key pair for SSH access  
- **user_data** (string, optional, default `null`) — User data script  
- **tags** (map(string), optional, default `{}`) — Extra tags to merge with defaults  

---

## Outputs

- **instance_id** — ID of the created EC2 instance  
- **public_ip** — Public IP address (if assigned)  

---

## Example Usage

```hcl
module "ec2_instance" {
  source = "../../modules/ec2_instance"

  name          = "demo-ec2"
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  subnet_id           = "subnet-0123456789abcdef"
  security_group_ids  = ["sg-0123456789abcdef"]
  associate_public_ip = true
  key_name            = "my-keypair"

  tags = {
    Owner = "DemoUser"
    Env   = "dev"
  }
}
```

---

## Notes

- If no `subnet_id` and `security_group_ids` are provided, the caller stack may use defaults (e.g., default VPC).  
- This module does not create networking resources; it only provisions an EC2 instance.  
