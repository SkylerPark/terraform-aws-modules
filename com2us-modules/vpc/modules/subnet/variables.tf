variable "name" {
  description = "Name to be use"
  type        = string
  default     = "default"
}

variable "vpc_id" {
  description = "(Required) The VPC ID."
  type        = string
}

variable "cidr_block" {
  description = "(Optional) The IPv4 CIDR block for the subnet."
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "(Optional) AZ for the subnet."
  type        = string
  default     = null
}

variable "map_public_ip_on_launch" {
  description = "(Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false."
  type        = bool
  default     = false
}

variable "assign_ipv6_address_on_creation" {
  description = "(Optional) Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. Default is false"
  type        = bool
  default     = false
}

variable "ipv6_cidr_block" {
  description = "(Optional) The IPv6 network range for the subnet, in CIDR notation. The subnet size must use a /64 prefix length."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
