resource "tls_private_key" "this" {
  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits
}
