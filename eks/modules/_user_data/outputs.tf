output "user_data" {
  description = "Base64 encoded user data rendered for the provided inputs"
  value       = try(local.int_linux_default_user_data, null)
}
