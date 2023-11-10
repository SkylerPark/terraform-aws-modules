variable "ssl" {
  description = "An optional description of this resource."
  type        = any
  default     = {}
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = null
}
