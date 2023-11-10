variable "name" {
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

