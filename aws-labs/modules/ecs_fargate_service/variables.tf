variable "name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "container_name" {
  type    = string
  default = "web"
}

variable "container_image" {
  type    = string
  default = "public.ecr.aws/nginx/nginx:latest"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "cpu" {
  type    = string
  default = "256"
}

variable "memory" {
  type    = string
  default = "512"
}

variable "cpu_architecture" {
  type    = string
  default = "X86_64"
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "subnet_ids" {
  description = "Explicit subnets (optional); empty -> default VPC subnets"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Explicit SGs (optional); empty -> default SG"
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}