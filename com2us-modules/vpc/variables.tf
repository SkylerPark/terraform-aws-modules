# common
variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "default"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# vpc
variable "vpc_id" {
  description = "The VPC ID."
  type        = string
  default     = null
}

variable "vpc_name" {
  description = "Name to be used on VPC"
  type        = string
  default     = null
}

variable "use_ipam_pool" {
  description = "Determines whether IPAM pool is used for CIDR allocation"
  type        = bool
  default     = false
}

variable "ipv4_ipam_pool_id" {
  description = "(Optional) The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR."
  type        = string
  default     = null
}

variable "ipv4_netmask_length" {
  description = "(Optional) The netmask length of the IPv4 CIDR you want to allocate to this VPC. Requires specifying a ipv4_ipam_pool_id."
  type        = number
  default     = null
}

variable "cidr" {
  description = "(Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`"
  type        = string
  default     = "0.0.0.0/0"
}

variable "enable_ipv6" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block."
  type        = bool
  default     = false
}

variable "ipv6_cidr" {
  description = "(Optional) IPv6 CIDR block to request from an IPAM Pool. Can be set explicitly or derived from IPAM using `ipv6_netmask_length`."
  type        = string
  default     = null
}

variable "ipv6_ipam_pool_id" {
  description = "(Optional) IPAM Pool ID for a IPv6 pool. Conflicts with `assign_generated_ipv6_cidr_block`."
  type        = string
  default     = null
}

variable "ipv6_netmask_length" {
  description = "(Optional) Netmask length to request from IPAM Pool. Conflicts with `ipv6_cidr_block`. This can be omitted if IPAM pool as a `allocation_default_netmask_length` set. Valid values: `56`."
  type        = number
  default     = null
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

# subnet
variable "subnets" {
  description = "A list of subnets inside the VPC"
  type        = any
  default     = {}
}

variable "subnet_tags" {
  description = "Additional tags for the Subnet"
  type        = map(string)
  default     = {}
}

# internet gateway
variable "create_internet_gateway" {
  description = "Controls if an Internet Gateway is created for public subnets and the related routes that connect them."
  type        = bool
  default     = true
}

variable "internet_gateway_name" {
  description = "Name to be used on Internet Gateway"
  type        = string
  default     = null
}

variable "internet_gateway_tags" {
  description = "Additional tags for the Internet Gateway"
  type        = map(string)
  default     = {}
}

# nat gateway
variable "nat_gateways" {
  description = "A list of Nat Gateway"
  type        = any
  default     = {}
}

variable "nat_gateway_tags" {
  description = "Additional tags for the Nat Gateway"
  type        = map(string)
  default     = {}
}

variable "eip_tags" {
  description = "Additional tags for the eip"
  type        = map(string)
  default     = {}
}

# route table
variable "route_tables" {
  description = "A list of Route Table"
  type        = any
  default     = {}
}

variable "route_table_tags" {
  description = "Additional tags for the Route Table"
  type        = map(string)
  default     = {}
}
