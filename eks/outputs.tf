################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = try(aws_eks_cluster.this.arn, null)
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = try(aws_eks_cluster.this.certificate_authority[0].data, null)
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = try(aws_eks_cluster.this.endpoint, null)
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = try(aws_eks_cluster.this.cluster_id, "")
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = try(aws_eks_cluster.this.name, "")
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = try(aws_eks_cluster.this.identity[0].oidc[0].issuer, null)
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = try(aws_eks_cluster.this.version, null)
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = try(aws_eks_cluster.this.platform_version, null)
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = try(aws_eks_cluster.this.status, null)
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = try(aws_eks_cluster.this.vpc_config[0].cluster_security_group_id, null)
}

################################################################################
# IRSA
################################################################################

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = try(replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", ""), null)
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = try(aws_iam_openid_connect_provider.oidc_provider[0].arn, null)
}

output "cluster_tls_certificate_sha1_fingerprint" {
  description = "The SHA1 fingerprint of the public key of the cluster's certificate"
  value       = try(data.tls_certificate.this[0].certificates[0].sha1_fingerprint, null)
}

################################################################################
# EKS Addons
################################################################################

output "cluster_addons" {
  description = "Map of attribute maps for all EKS cluster addons enabled"
  # value       = merge(aws_eks_addon.this, aws_eks_addon.before_compute)
  value = aws_eks_addon.this
}

################################################################################
# EKS Identity Provider
################################################################################

# output "cluster_identity_providers" {
#   description = "Map of attribute maps for all EKS identity providers enabled"
#   value       = aws_eks_identity_provider_config.this
# }

################################################################################
# CloudWatch Log Group
################################################################################

# output "cloudwatch_log_group_name" {
#   description = "Name of cloudwatch log group created"
#   value       = try(aws_cloudwatch_log_group.this[0].name, null)
# }

# output "cloudwatch_log_group_arn" {
#   description = "Arn of cloudwatch log group created"
#   value       = try(aws_cloudwatch_log_group.this[0].arn, null)
# }

################################################################################
# EKS Managed Node Group
################################################################################

output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks_managed_node_group
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = compact(flatten([for group in module.eks_managed_node_group : group.node_group_autoscaling_group_names]))
}

################################################################################
# Fargate Profile
################################################################################

output "fargate_profiles" {
  description = "Map of attribute maps for all EKS Fargate Profiles created"
  value       = module.fargate_profile
}

