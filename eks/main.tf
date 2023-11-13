locals {
  cluster_name = var.cluster_name != null ? var.cluster_name : replace("${var.name}-cluster-${var.version}", ".", "-")
}

resource "aws_eks_cluster" "this" {
  name                      = local.cluster_name
  role_arn                  = var.iam_role_arn
  version                   = var.cluster_version
  enabled_cluster_log_types = var.cluster_enabled_log_types

  vpc_config {
    security_group_ids      = var.cluster_additional_security_group_ids
    subnet_ids              = coalescelist(var.control_plane_subnet_ids, var.subnet_ids)
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }
}
