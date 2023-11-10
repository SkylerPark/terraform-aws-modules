output "key_pair_id" {
  description = "The key pair ID."
  value       = module.key_pair.key_pair_id
}

output "key_name" {
  description = "The key pair name"
  value       = module.key_pair.key_name
}

output "private_key_pem" {
  description = "Private key data in PEM (RFC 1421) format"
  value       = try(module.tls_private_key[0].private_key_pem, "")
  sensitive   = true
}
