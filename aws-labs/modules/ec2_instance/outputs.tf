output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP (if assigned)"
  value       = aws_instance.this.public_ip
}