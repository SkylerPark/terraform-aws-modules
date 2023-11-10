resource "aws_sns_topic_subscription" "this" {
  topic_arn                       = var.topic_arn
  protocol                        = var.protocol
  endpoint                        = var.endpoint
  confirmation_timeout_in_minutes = var.confirmation_timeout_in_minutes
  endpoint_auto_confirms          = var.endpoint_auto_confirms
}
