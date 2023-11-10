variable "name" {
  description = "Name to be use"
  type        = string
  default     = "default"
}

variable "instance" {
  description = "EC2 instance ID."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
