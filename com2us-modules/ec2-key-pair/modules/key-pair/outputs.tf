output "key_pair_id" {
  description = "The key pair ID."
  value       = aws_key_pair.this.key_pair_id
}

output "key_name" {
  description = "The key pair name"
  value       = aws_key_pair.this.key_name
}
