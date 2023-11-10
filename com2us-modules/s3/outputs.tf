output "id" {
  description = "s3 bucket id"
  value       = module.s3_bucket[0].id
}

output "arn" {
  description = "s3 bucket arn"
  value       = module.s3_bucket[0].arn
}
