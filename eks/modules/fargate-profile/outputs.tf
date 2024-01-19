output "fargate_profile_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Fargate Profile"
  value       = try(aws_eks_fargate_profile.this.arn, null)
}

output "fargate_profile_id" {
  description = "EKS Cluster name and EKS Fargate Profile name separated by a colon (`:`)"
  value       = try(aws_eks_fargate_profile.this.id, null)
}

output "fargate_profile_status" {
  description = "Status of the EKS Fargate Profile"
  value       = try(aws_eks_fargate_profile.this.status, null)
}

output "fargate_profile_pod_execution_role_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Fargate Profile Pod execution role ARN"
  value       = try(aws_eks_fargate_profile.this.pod_execution_role_arn, null)
}
