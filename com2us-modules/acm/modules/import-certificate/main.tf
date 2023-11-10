resource "aws_acm_certificate" "this" {
  for_each          = var.ssl
  private_key       = each.value.private_key_pem
  certificate_body  = each.value.cert_pem
  certificate_chain = each.value.chain_pem
  tags              = merge({ Name = each.key }, var.tags)
}
