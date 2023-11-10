output "id" {
  description = "The ID of the NAT Gateway."
  value       = aws_nat_gateway.this.id
}

output "name" {
  description = "The Name of the NAT Gateway."
  value       = var.name
}

output "public_ip" {
  description = "The Elastic IP address associated with the NAT gateway."
  value       = aws_nat_gateway.this.public_ip
}
