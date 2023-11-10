variable "subnet_id" {
  description = "(Optional) The subnet ID to create an association."
  type        = string
  default     = null
}

variable "gateway_id" {
  description = "(Optional) The gateway ID to create an association."
  type        = string
  default     = null
}

variable "route_table_id" {
  description = "(Required) The ID of the routing table to associate with."
  type        = string
}
