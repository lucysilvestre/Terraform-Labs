output "instance_id" {
  description = "ID da instância"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "IP público"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "DNS público"
  value       = aws_instance.web.public_dns
}
