# Reusable EC2 module — resources only (no nested module calls)

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip
  key_name                    = var.key_name
  user_data                   = try(var.user_data, null)

  # Optional hardening (enable by uncommenting)
  # metadata_options {
  #   http_tokens = "required" # IMDSv2 only
  # }

  tags = merge(
    {
      Name      = var.name
      ManagedBy = "Terraform"
    },
    var.tags
  )
}