variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN for the Fargate profile. Required if `create_iam_role` is set to `false`"
  type        = string
  default     = null
}

################################################################################
# Fargate Profile
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the EKS Fargate Profile"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the EKS Fargate Profile"
  type        = list(string)
  default     = []
}

variable "selectors" {
  description = "Configuration block(s) for selecting Kubernetes Pods to execute with this Fargate Profile"
  type        = any
  default     = []
}

variable "timeouts" {
  description = "Create and delete timeout configurations for the Fargate Profile"
  type        = map(string)
  default     = {}
}
