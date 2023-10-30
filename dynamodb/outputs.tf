output "id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.this.id
}

output "name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.this.name
}
