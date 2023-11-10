output "id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "name" {
  description = "The Name of the VPC"
  value       = var.name
}

output "cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = aws_vpc.this.default_security_group_id
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = aws_vpc.this.default_route_table_id
}
