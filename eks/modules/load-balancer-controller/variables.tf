variable "name" {
  description = "(Required) Release name. The length must not be longer than 53 characters."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "repository" {
  description = "(Optional) Repository URL where to locate the requested chart."
  type        = string
  default     = "https://aws.github.io/eks-charts"
}

variable "chart" {
  description = "(Required) Chart name to be installed."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "namespace" {
  description = "(Optional) The namespace to install the release into. Defaults to default."
  type        = string
  default     = "kube-system"
}

variable "cluster_name" {
  description = "Name to Helm EKS Cluster"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  default     = null
}

variable "openid_connect_arn" {
  description = "EKS openid connect provider arn"
  type        = string
  default     = null
}

variable "openid_connect_url" {
  description = "EKS openid connect provider url"
  type        = string
  default     = null
}

variable "region" {
  description = "Helm Setting Region Variable"
  type        = string
  default     = null
}
