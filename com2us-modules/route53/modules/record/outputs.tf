output "name" {
  description = "The name of the record."
  value       = aws_route53_record.this.name
}

output "records" {
  description = "built using the zone domain and name"
  value       = aws_route53_record.this.records
}
