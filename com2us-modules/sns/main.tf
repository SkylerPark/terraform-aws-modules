module "sns_topic" {
  source                      = "./modules/sns-topic"
  count                       = var.create_topic ? 1 : 0
  name                        = var.topic_name
  display_name                = var.display_name
  policy                      = var.policy
  delivery_policy             = var.delivery_policy
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.content_based_deduplication
  kms_master_key_id           = var.kms_master_key_id
  tags                        = var.tags
}

module "sns_topic_subscription" {
  source                          = "./modules/sns_topic_subscription"
  count                           = var.create_topic_subscription ? 1 : 0
  topic_arn                       = var.topic_arn == null ? module.sns_topic[0].arn : var.topic_arn
  protocol                        = var.topic_subscription_protocol
  endpoint                        = var.topic_subscription_endpoint == null ? null : var.topic_subscription_endpoint
  confirmation_timeout_in_minutes = var.confirmation_timeout_in_minutes
  endpoint_auto_confirms          = var.endpoint_auto_confirms
}
