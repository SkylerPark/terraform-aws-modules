variable "secondary_subnets" {
  description = "Map of Secondary Subnets"
  type        = any
  default     = {}
}

variable "cluster_primary_security_group_id" {
  description = "The ID of the EKS cluster primary security group to associate with the instance(s). This is the security group that is automatically created by the EKS service"
  type        = string
  default     = null
}
