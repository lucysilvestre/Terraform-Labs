variable "instance_name" {
  description = "Instance Name"
  type        = string
  default     = "pilu-ec2"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "ssh_ingress_cidr" {
  description = "CIDR Allow SSH"
  type        = string
  default     = "0.0.0.0/0"
}