variable "create_topic" {
  description = "topic create"
  type        = bool
  default     = false
}

variable "topic_name" {
  description = "(Optional) The name of the topic. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. For a FIFO (first-in-first-out) topic, the name must end with the .fifo suffix. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix"
  type        = string
}

variable "display_name" {
  description = "(Optional) The display name for the topic"
  type        = string
}

variable "policy" {
  description = "(Optional) The fully-formed AWS policy as JSON. For more information about building AWS IAM policy documents with Terraform"
  type        = any
  default     = null
}

variable "delivery_policy" {
  description = "(Optional) The SNS delivery policy"
  type        = string
  default     = null
}

variable "fifo_topic" {
  description = "(Optional) Boolean indicating whether or not to create a FIFO (first-in-first-out) topic (default is false)."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Optional) Enables content-based deduplication for FIFO topics."
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "(Optional) The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags. If configured with a provider"
  type        = map(any)
  default     = {}
}

variable "create_topic_subscription" {
  description = "topic_subscription create"
  type        = bool
  default     = false
}

variable "topic_arn" {
  description = "topic arn"
  type        = string
  default     = null
}

variable "topic_subscription_protocol" {
  description = "(Required) Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application. Protocols email, email-json, http and https are also valid but partially supported. See details below."
  type        = string
  default     = null
}

variable "topic_subscription_endpoint" {
  description = "(Required) Endpoint to send data to. The contents vary with the protocol. See details below."
  type        = string
  default     = null
}

variable "confirmation_timeout_in_minutes" {
  description = "(Optional) Integer indicating number of minutes to wait in retrying mode for fetching subscription arn before marking it as failure. Only applicable for http and https protocols. Default is 1."
  type        = number
  default     = null
}

variable "endpoint_auto_confirms" {
  description = "(Optional) Whether the endpoint is capable of auto confirming subscription (e.g., PagerDuty). Default is false."
  type        = bool
  default     = null
}
