output "subnet_id" {
  description = "The id of subnet."
  value       = aws_default_subnet.default.id
}

output "availability_zone" {
  description = "The availability_zone of subnet."
  value       = aws_default_subnet.default.availability_zone
}
