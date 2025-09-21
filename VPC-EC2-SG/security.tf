# Security Group permitindo SSH and HTTP a partir do CIDR configurado
resource "aws_security_group" "ssh" {
  name        = "${var.instance_name}-sg-ssh-web"
  description = "SSH (22) e HTTP (80)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH for allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "All outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.instance_name}-sg-ssh-web"
  }
}