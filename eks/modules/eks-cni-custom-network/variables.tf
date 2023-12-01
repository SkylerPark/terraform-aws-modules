variable "secondary_subnets" {
  description = "Map of Secondary Subnets"
  type        = any
  default     = {}
}

variable "security_group_id" {
  description = "security group IDs to associate"
  type        = string
  default     = null
}
