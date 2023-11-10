variable "security_group_id" {
  description = "(Required) Security group to apply this rule to."
  type        = string
  default     = null
}

variable "type" {
  description = "(Required) Type of rule being created."
  type        = string
  default     = null
}

variable "from_port" {
  description = "(Required) Start port"
  type        = number
  default     = null
}

variable "to_port" {
  description = "(Required) End port"
  type        = number
  default     = null
}

variable "protocol" {
  description = "(Required) Protocol."
  type        = string
  default     = null
}

variable "cidr_blocks" {
  description = "(Optional) List of CIDR blocks."
  type        = list(string)
  default     = null
}

variable "ipv6_cidr_blocks" {
  description = "(Optional) List of IPv6 CIDR blocks."
  type        = list(string)
  default     = null
}

variable "prefix_list_ids" {
  description = "(Optional) List of Prefix List IDs."
  type        = list(string)
  default     = null
}

variable "source_security_group_id" {
  description = "(Optional) Security group id to allow access to/from, depending on the type. "
  type        = string
  default     = null
}

variable "self" {
  description = "(Optional) Whether the security group itself will be added as a source to this ingress rule."
  type        = bool
  default     = null
}

variable "description" {
  description = "(Optional) Description of the rule."
  type        = string
  default     = null
}
