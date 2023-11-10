output "id" {
  description = "route53 id"
  value       = aws_route53_zone.this.id
}

output "zone_id" {
  description = "route53 zone id"
  value       = aws_route53_zone.this.zone_id
}

output "name" {
  description = "route53 name"
  value       = aws_route53_zone.this.name
}
