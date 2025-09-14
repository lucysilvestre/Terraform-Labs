// Reusable EC2 module — inputs
// Keep module inputs minimal and explicit for clarity and reuse.

variable "name" {
  description = "Instance name tag"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID (optional; omit to use provider defaults)"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "Security groups (optional; empty -> default SG)"
  type        = list(string)
  default     = []
}

variable "associate_public_ip" {
  description = "Associate a public IP"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "EC2 Key Pair name (optional)"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}