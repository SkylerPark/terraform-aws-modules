variable "name" {
  description = "Name to be use"
  type        = string
  default     = "default"
}

variable "vpc_id" {
  description = "(Required) The VPC ID."
  type        = string
}

variable "routes" {
  description = "(Optional) A list of route objects."
  type        = any
  default     = []
}

variable "propagating_vgws" {
  description = "(Optional) A list of virtual gateways for propagation."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "(Optional) A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
