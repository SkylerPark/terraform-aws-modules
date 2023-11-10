output "id" {
  description = "bucket id"
  value       = aws_s3_bucket.this.id
}

output "arn" {
  description = "bucket arn"
  value       = aws_s3_bucket.this.arn
}
