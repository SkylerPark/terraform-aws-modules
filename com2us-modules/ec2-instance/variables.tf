variable "vpc_id" {
  description = "(Required) The VPC ID."
  type        = string
  default     = null
}

variable "hostname" {
  description = "HostName Prefix Ex) rnd-was-test"
  type        = string
  default     = "default"
}

variable "default_instance" {
  description = "Default Instance List"
  type        = list(string)
  default     = []
}

variable "instances" {
  description = "Instance Parameter list"
  type        = any
  default     = {}
}

variable "subnets" {
  description = "subnet list"
  type        = list(string)
  default     = []
}

variable "subnet_name" {
  description = "subnet name string"
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private", "database"], var.subnet_name)
    error_message = "Subnet Name only public or private or database, options are: ${var.subnet_name}"
  }
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = null
}

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "(Optional, List) Security Group ID List"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance; which can be managed using the `aws_key_pair` resource"
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
  default     = null
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = false
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  type        = list(any)
  default     = []
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = list(map(string))
  default     = []
}

variable "attachment_ebs_block_device" {
  description = "Additional attachment EBS block devices to attach to the instance"
  type        = list(map(string))
  default     = []
}

variable "create_eip" {
  description = "eip enable"
  type        = bool
  default     = false
}

variable "is_lb" {
  description = "lb attachements"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "instance_tags" {
  description = "Additional tags for the Instance."
  type        = map(string)
  default     = {}
}

variable "eip_tags" {
  description = "Additional tags for the EIP."
  type        = map(string)
  default     = {}
}

variable "enable_volume_tags" {
  description = "Whether to enable volume tags (if enabled it conflicts with root_block_device tags)"
  type        = bool
  default     = false
}

variable "volume_tags" {
  description = "A mapping of tags to assign to the devices created by the instance at launch time"
  type        = map(string)
  default     = {}
}

variable "metadata_options" {
  description = "Customize the metadata options of the instance"
  type        = map(string)
  default = {
    "http_endpoint"               = "enabled"
    "http_put_response_hop_limit" = 1
    "http_tokens"                 = "optional"
  }
}

variable "os" {
  description = "instance os name"
  type        = string
  default     = null
}

variable "os_version" {
  description = "instance os version"
  type        = string
  default     = null
}

variable "availability_zones" {
  description = "availability zone list"
  type        = list(string)
  default     = []
}

################################################################################
# Security Group
################################################################################

variable "create_security_group" {
  description = "Determines if a security group is created"
  type        = bool
  default     = false
}

variable "security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = ""
}

variable "temp_security_groups" {
  description = "Temp Security group rules to add to the security group created"
  type        = any
  default     = {}
}

variable "ingress_with_source_security_group_id" {
  description = "List of ingress rules to create where 'source_security_group_id' is used"
  type        = list(map(string))
  default     = []
}

variable "ingress_with_cidr_blocks" {
  description = "List of ingress rules to create where 'cidr_blocks' is used"
  type        = list(map(string))
  default     = []
}

variable "ingress_with_ipv6_cidr_blocks" {
  description = "List of ingress rules to create where 'ipv6_cidr_blocks' is used"
  type        = list(map(string))
  default     = []
}

variable "egress_with_source_security_group_id" {
  description = "List of ingress rules to create where 'source_security_group_id' is used"
  type        = list(map(string))
  default     = []
}

variable "egress_with_cidr_blocks" {
  description = "List of egress rules to create where 'cidr_blocks' is used"
  type        = list(map(string))
  default     = []
}

variable "egress_with_ipv6_cidr_blocks" {
  description = "List of egress rules to create where 'ipv6_cidr_blocks' is used"
  type        = list(map(string))
  default     = []
}
