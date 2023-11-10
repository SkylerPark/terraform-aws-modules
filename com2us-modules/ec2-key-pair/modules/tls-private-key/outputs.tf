output "public_key_openssh" {
  description = "(String) The public key data in 'Authorized Keys' format. This is not populated for ECDSA with curve P224, as it is not supported."
  value       = tls_private_key.this.public_key_openssh
}

output "private_key_pem" {
  description = "Private key data in PEM (RFC 1421) format"
  value       = try(trimspace(tls_private_key.this.private_key_pem), "")
  sensitive   = true
}
