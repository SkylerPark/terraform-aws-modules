variable "name" {
  description = "Name to be use"
  type        = string
  default     = "default"
}

variable "allocation_id" {
  description = "(Optional) The Allocation ID of the Elastic IP address for the gateway. Required for connectivity_type of public."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "(Required) The Subnet ID of the subnet in which to place the gateway."
  type        = string
}

variable "tags" {
  description = "(Optional) A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
