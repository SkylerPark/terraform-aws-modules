output "id" {
  description = "The ID of the subnet"
  value       = aws_subnet.this.id
}

output "name" {
  description = "The Name of the subnet"
  value       = var.name
}

output "availability_zone" {
  description = "The AZ of the subnet"
  value       = aws_subnet.this.availability_zone
}

output "cidr_block" {
  description = "The CIDR of the subnet"
  value       = aws_subnet.this.cidr_block
}
