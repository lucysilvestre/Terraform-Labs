data "aws_ami" "Linux_server" {
  owners      = ["137112412989"] # AWS
  most_recent = true

  filter {
    name   = "name"
    values = ["Linux_server-ami-*-x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

# VPC default (For the Security Group)
data "aws_vpc" "default" {
  default = true
}

# Create EC2 Instance EC2
resource "aws_instance" "web" {
  ami           = data.aws_ami.Linux_server.id
  instance_type = var.instance_type

  # Attach the SG (use always vpc_security_group_ids in VPC)
  vpc_security_group_ids = [aws_security_group.ssh.id]

  # Public IP for Internet
  associate_public_ip_address = true

  tags = {
    Name = var.instance_name
  }
}
