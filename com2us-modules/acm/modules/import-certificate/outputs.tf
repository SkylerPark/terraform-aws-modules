output "id" {
  description = "The ID of the SSL certificate"
  value       = { for k, v in var.ssl : k => aws_acm_certificate.this[k].id }
}
