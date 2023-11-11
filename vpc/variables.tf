variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "The VPC ID."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# VPC
################################################################################

variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = null
}

variable "cidr_block" {
  description = "(Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

################################################################################
# Subnet
################################################################################

variable "subnets" {
  description = "Subnet List"
  type        = list(any)
  default     = []
}

variable "subnet_tags" {
  description = "Additional tags for the Subnet"
  type        = map(string)
  default     = {}
}

################################################################################
# Internet Gateway
################################################################################

variable "igw_name" {
  description = "IGW Name"
  type        = string
  default     = null
}

variable "create_igw" {
  description = "Controls if an Internet Gateway is created for public subnets and the related routes that connect them"
  type        = bool
  default     = false
}

variable "igw_tags" {
  description = "Additional tags for the internet gateway"
  type        = map(string)
  default     = {}
}

################################################################################
# NAT Gateway
################################################################################

variable "create_nat_gw" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone."
  type        = bool
  default     = false
}

variable "nat_gw_tags" {
  description = "Additional tags for the NAT gateways"
  type        = map(string)
  default     = {}
}

variable "nat_eip_tags" {
  description = "Additional tags for the NAT EIP"
  type        = map(string)
  default     = {}
}

################################################################################
# Route Table
################################################################################

variable "route_tables" {
  description = "Route Table List"
  type        = any
  default     = []
}

variable "route_table_tags" {
  description = "Additional tags for the Route Table"
  type        = map(string)
  default     = {}
}

