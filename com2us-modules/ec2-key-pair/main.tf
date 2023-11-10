module "key_pair" {
  source     = "./modules/key-pair"
  key_name   = var.key_name
  public_key = var.create_private_key ? trimspace(module.tls_private_key[0].public_key_openssh) : var.public_key

  tags = var.tags
}

module "tls_private_key" {
  source = "./modules/tls-private-key"
  count  = var.create_private_key ? 1 : 0

  algorithm = var.private_key_algorithm
  rsa_bits  = var.private_key_rsa_bits
}
