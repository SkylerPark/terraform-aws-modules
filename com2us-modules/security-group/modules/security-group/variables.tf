variable "name" {
  description = "(Optional, Forces new resource) Name of the security group."
  type        = string
  default     = null
}

variable "description" {
  description = "(Optional, Forces new resource) Security group description."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "(Optional, Forces new resource) VPC ID."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
