resource "aws_sns_topic" "this" {
  name                        = var.name
  display_name                = var.display_name
  policy                      = jsonencode(var.policy)
  delivery_policy             = var.delivery_policy
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.content_based_deduplication
  kms_master_key_id           = var.kms_master_key_id
  tags                        = var.tags
}
