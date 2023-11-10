output "id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "name" {
  description = "The Name of the Internet Gateway."
  value       = var.name
}
