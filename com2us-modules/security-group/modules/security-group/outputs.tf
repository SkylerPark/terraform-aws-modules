output "id" {
  description = "ID of the security group."
  value       = aws_security_group.this.id
}

output "vpc_id" {
  description = "VPC ID of the security group."
  value       = aws_security_group.this.vpc_id
}

output "name" {
  description = "Name of the security group."
  value       = aws_security_group.this.name
}
