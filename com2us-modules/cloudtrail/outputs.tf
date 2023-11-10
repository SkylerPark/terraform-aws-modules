output "cloudtrail_id" {
  value       = aws_cloudtrail.this.id
  description = "The name of the trail"
}

output "cloudtrail_home_region" {
  value       = aws_cloudtrail.this.home_region
  description = "The region in which the trail was created"
}

output "cloudtrail_arn" {
  value       = aws_cloudtrail.this.arn
  description = "The Amazon Resource Name of the trail"
}
