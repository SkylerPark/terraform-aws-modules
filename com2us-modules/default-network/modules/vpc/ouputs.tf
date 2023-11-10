output "vpc_id" {
  description = "VPC ID"
  value       = aws_default_vpc.default.id
}

output "default_route_table_id" {
  description = "Default Route Talbe ID"
  value       = aws_default_vpc.default.default_route_table_id
}
