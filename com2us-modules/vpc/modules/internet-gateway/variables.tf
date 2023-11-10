variable "name" {
  description = "Name to be use"
  type        = string
  default     = "default"
}

variable "vpc_id" {
  description = "(Required) The VPC ID."
  type        = string
}

variable "tags" {
  description = "(Optional) A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
