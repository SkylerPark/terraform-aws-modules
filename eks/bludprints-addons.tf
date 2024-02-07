locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name

  oidc_provider_arn = aws_iam_openid_connect_provider.oidc_provider[0].arn
}

################################################################################
# AWS Load Balancer Controller
################################################################################
locals {
  aws_load_balancer_controller_service_account = try(var.aws_load_balancer_controller.service_account_name, "aws-load-balancer-controller")
  aws_load_balancer_controller_namespace       = try(var.aws_load_balancer_controller.namespace, "kube-system")
}

module "load_balancer_controller" {
  create = var.enable_aws_load_balancer_controller
  source = "./modules/blueprints-addon"

  name        = try(var.aws_load_balancer_controller.name, "aws-load-balancer-controller")
  description = try(var.aws_load_balancer_controller.description, "A Helm chart to deploy aws-load-balancer-controller for ingress resources")
  namespace   = local.aws_load_balancer_controller_namespace
  # namespace creation is false here as kube-system already exists by default
  create_namespace = try(var.aws_load_balancer_controller.create_namespace, false)
  chart            = try(var.aws_load_balancer_controller.chart, "aws-load-balancer-controller")
  chart_version    = try(var.aws_load_balancer_controller.chart_version, "1.6.2")
  repository       = try(var.aws_load_balancer_controller.repository, "https://aws.github.io/eks-charts")
  values           = try(var.aws_load_balancer_controller.values, [])

  timeout                    = try(var.aws_load_balancer_controller.timeout, null)
  repository_key_file        = try(var.aws_load_balancer_controller.repository_key_file, null)
  repository_cert_file       = try(var.aws_load_balancer_controller.repository_cert_file, null)
  repository_ca_file         = try(var.aws_load_balancer_controller.repository_ca_file, null)
  repository_username        = try(var.aws_load_balancer_controller.repository_username, null)
  repository_password        = try(var.aws_load_balancer_controller.repository_password, null)
  devel                      = try(var.aws_load_balancer_controller.devel, null)
  verify                     = try(var.aws_load_balancer_controller.verify, null)
  keyring                    = try(var.aws_load_balancer_controller.keyring, null)
  disable_webhooks           = try(var.aws_load_balancer_controller.disable_webhooks, null)
  reuse_values               = try(var.aws_load_balancer_controller.reuse_values, null)
  reset_values               = try(var.aws_load_balancer_controller.reset_values, null)
  force_update               = try(var.aws_load_balancer_controller.force_update, null)
  recreate_pods              = try(var.aws_load_balancer_controller.recreate_pods, null)
  cleanup_on_fail            = try(var.aws_load_balancer_controller.cleanup_on_fail, null)
  max_history                = try(var.aws_load_balancer_controller.max_history, null)
  atomic                     = try(var.aws_load_balancer_controller.atomic, null)
  skip_crds                  = try(var.aws_load_balancer_controller.skip_crds, null)
  render_subchart_notes      = try(var.aws_load_balancer_controller.render_subchart_notes, null)
  disable_openapi_validation = try(var.aws_load_balancer_controller.disable_openapi_validation, null)
  wait                       = try(var.aws_load_balancer_controller.wait, false)
  wait_for_jobs              = try(var.aws_load_balancer_controller.wait_for_jobs, null)
  dependency_update          = try(var.aws_load_balancer_controller.dependency_update, null)
  replace                    = try(var.aws_load_balancer_controller.replace, null)
  lint                       = try(var.aws_load_balancer_controller.lint, null)

  postrender = try(var.aws_load_balancer_controller.postrender, [])
  set = concat([
    {
      name  = "serviceAccount.name"
      value = local.aws_load_balancer_controller_service_account
    },
    {
      name  = "clusterName"
      value = local.cluster_name
    }],
    try(var.aws_load_balancer_controller.set, [])
  )
  set_sensitive = try(var.aws_load_balancer_controller.set_sensitive, [])

  # IAM role for service account (IRSA)
  create_role                   = try(var.aws_load_balancer_controller.create_role, true)
  set_irsa_names                = ["serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  role_name                     = try(var.aws_load_balancer_controller.role_name, "AmazonEKSLoadBalancerControllerRole")
  role_name_use_prefix          = try(var.aws_load_balancer_controller.role_name_use_prefix, true)
  role_path                     = try(var.aws_load_balancer_controller.role_path, "/")
  role_permissions_boundary_arn = lookup(var.aws_load_balancer_controller, "role_permissions_boundary_arn", null)
  role_description              = try(var.aws_load_balancer_controller.role_description, "IRSA for aws-load-balancer-controller project")
  role_policies                 = lookup(var.aws_load_balancer_controller, "role_policies", {})

  create_policy          = try(var.aws_load_balancer_controller.create_policy, true)
  policy_name            = try(var.aws_load_balancer_controller.policy_name, "AmazonEKSLoadBalancerControllerPolicy")
  policy_name_use_prefix = try(var.aws_load_balancer_controller.policy_name_use_prefix, true)
  policy_path            = try(var.aws_load_balancer_controller.policy_path, "/")
  policy_description     = try(var.aws_load_balancer_controller.policy_description, "IAM Policy for AWS Load Balancer Controller")
  policy_document        = try(var.aws_load_balancer_controller.policy_document, "")


  oidc_providers = {
    this = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.aws_load_balancer_controller_service_account
    }
  }

  depends_on = [module.eks_managed_node_group, module.fargate_profile, aws_eks_addon.this]
}

################################################################################
# Karpenter
################################################################################

locals {
  karpenter_service_account = try(var.karpenter.service_account_name, "karpenter")
  karpenter_namespace       = try(var.karpenter.namespace, "karpenter")
}

module "karpenter" {
  create = var.enable_karpenter
  source = "./modules/blueprints-addon"

  name             = try(var.karpenter.name, "karpenter")
  description      = try(var.karpenter.description, "A Helm chart to deploy Karpenter")
  namespace        = local.karpenter_namespace
  create_namespace = try(var.karpenter.create_namespace, true)
  chart            = try(var.karpenter.chart, "karpenter")
  chart_version    = try(var.karpenter.chart_version, "0.16.3")
  repository       = try(var.karpenter.repository, "https://charts.karpenter.sh")
  values           = try(var.karpenter.values, [])

  timeout                    = try(var.karpenter.timeout, null)
  repository_key_file        = try(var.karpenter.repository_key_file, null)
  repository_cert_file       = try(var.karpenter.repository_cert_file, null)
  repository_ca_file         = try(var.karpenter.repository_ca_file, null)
  repository_username        = try(var.karpenter.repository_username, null)
  repository_password        = try(var.karpenter.repository_password, null)
  devel                      = try(var.karpenter.devel, null)
  verify                     = try(var.karpenter.verify, null)
  keyring                    = try(var.karpenter.keyring, null)
  disable_webhooks           = try(var.karpenter.disable_webhooks, null)
  reuse_values               = try(var.karpenter.reuse_values, null)
  reset_values               = try(var.karpenter.reset_values, null)
  force_update               = try(var.karpenter.force_update, null)
  recreate_pods              = try(var.karpenter.recreate_pods, null)
  cleanup_on_fail            = try(var.karpenter.cleanup_on_fail, null)
  max_history                = try(var.karpenter.max_history, null)
  atomic                     = try(var.karpenter.atomic, null)
  skip_crds                  = try(var.karpenter.skip_crds, null)
  render_subchart_notes      = try(var.karpenter.render_subchart_notes, null)
  disable_openapi_validation = try(var.karpenter.disable_openapi_validation, null)
  wait                       = try(var.karpenter.wait, false)
  wait_for_jobs              = try(var.karpenter.wait_for_jobs, null)
  dependency_update          = try(var.karpenter.dependency_update, null)
  replace                    = try(var.karpenter.replace, null)
  lint                       = try(var.karpenter.lint, null)

  postrender = try(var.karpenter.postrender, [])
  set = concat([
    {
      name  = "clusterEndpoint"
      value = aws_eks_cluster.this.endpoint
    },
    {
      name  = "clusterName"
      value = local.cluster_name
    },
    {
      name  = "aws.defaultInstanceProfile"
      value = var.karpenter.default_instance_profile
    }],
    try(var.karpenter.set, [])
  )
  set_sensitive = try(var.karpenter.set_sensitive, [])

  # IAM role for service account (IRSA)
  create_role                   = try(var.karpenter.create_role, true)
  set_irsa_names                = ["serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  role_name                     = try(var.karpenter.role_name, "KarpenterControllerRole")
  role_name_use_prefix          = try(var.karpenter.role_name_use_prefix, true)
  role_path                     = try(var.karpenter.role_path, "/")
  role_permissions_boundary_arn = lookup(var.karpenter, "role_permissions_boundary_arn", null)
  role_description              = try(var.karpenter.role_description, "IRSA for karpenter project")
  role_policies                 = lookup(var.karpenter, "role_policies", {})

  create_policy          = try(var.karpenter.create_policy, true)
  policy_name            = try(var.karpenter.policy_name, "KarpenterControllerPolicy")
  policy_name_use_prefix = try(var.karpenter.policy_name_use_prefix, true)
  policy_path            = try(var.karpenter.policy_path, "/")
  policy_description     = try(var.karpenter.policy_description, "IAM Policy for Karpenter")
  policy_document        = try(var.karpenter.policy_document, "")

  oidc_providers = {
    this = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.karpenter_service_account
    }
  }

  depends_on = [module.eks_managed_node_group, module.fargate_profile, aws_eks_addon.this]
}

resource "time_sleep" "karpenter" {
  count           = var.enable_karpenter ? 1 : 0
  create_duration = "30s"
  depends_on      = [module.karpenter]
}

resource "kubectl_manifest" "provisioner" {
  count = var.enable_karpenter ? 1 : 0
  yaml_body = templatefile(
    "${path.module}/templates/karpenter-provisioner.yaml.tmpl",
    {
      requirements = var.karpenter.provisioner_requirements
    }
  )
  depends_on = [
    time_sleep.karpenter
  ]
  lifecycle {
    ignore_changes  = all
    prevent_destroy = true
  }
}

resource "kubectl_manifest" "aws_node_template" {
  count = var.enable_karpenter ? 1 : 0
  yaml_body = templatefile(
    "${path.module}/templates/karpenter-node-template.yaml.tmpl",
    {
      subnet_selector              = try(var.karpenter.node_template.subnet_selector, "${local.cluster_name}")
      security_group_selector      = try(var.karpenter.node_template.security_group_selector, "${local.cluster_name}")
      ami_family                   = try(var.karpenter.node_template.ami_family, "AL2")
      volume_size                  = try(var.karpenter.node_template.volume_size, "50G")
      volume_type                  = try(var.karpenter.node_template.volume_type, "gp3")
      volume_iops                  = try(var.karpenter.node_template.volume_iops, 3000)
      volume_throughput            = try(var.karpenter.node_template.volume_throughput, 125)
      volume_delete_on_termination = try(var.karpenter.node_template.volume_delete_on_termination, true)
      karpenter_node_name          = try(var.karpenter.node_template.karpenter_node_name, "${local.cluster_name}-node")
    }
  )
  depends_on = [
    kubectl_manifest.provisioner
  ]
  lifecycle {
    ignore_changes  = all
    prevent_destroy = true
  }
}

################################################################################
# Argo Rollouts
################################################################################
module "argo-rollouts" {
  create = var.enable_argo_rollouts
  source = "./modules/blueprints-addon"

  name             = try(var.argo_rollouts.name, "argo-rollouts")
  description      = try(var.argo_rollouts.description, "A Helm chart for Argo Rollouts")
  namespace        = try(var.argo_rollouts.namespace, "argo-rollouts")
  create_namespace = try(var.argo_rollouts.create_namespace, true)
  chart            = try(var.argo_rollouts.chart, "argo-rollouts")
  chart_version    = try(var.argo_rollouts.chart_version, "2.34.1")
  repository       = try(var.argo_rollouts.repository, "https://argoproj.github.io/argo-helm")
  values           = try(var.argo_rollouts.values, [])

  timeout                    = try(var.argo_rollouts.timeout, null)
  repository_key_file        = try(var.argo_rollouts.repository_key_file, null)
  repository_cert_file       = try(var.argo_rollouts.repository_cert_file, null)
  repository_ca_file         = try(var.argo_rollouts.repository_ca_file, null)
  repository_username        = try(var.argo_rollouts.repository_username, null)
  repository_password        = try(var.argo_rollouts.repository_password, null)
  devel                      = try(var.argo_rollouts.devel, null)
  verify                     = try(var.argo_rollouts.verify, null)
  keyring                    = try(var.argo_rollouts.keyring, null)
  disable_webhooks           = try(var.argo_rollouts.disable_webhooks, null)
  reuse_values               = try(var.argo_rollouts.reuse_values, null)
  reset_values               = try(var.argo_rollouts.reset_values, null)
  force_update               = try(var.argo_rollouts.force_update, null)
  recreate_pods              = try(var.argo_rollouts.recreate_pods, null)
  cleanup_on_fail            = try(var.argo_rollouts.cleanup_on_fail, null)
  max_history                = try(var.argo_rollouts.max_history, null)
  atomic                     = try(var.argo_rollouts.atomic, null)
  skip_crds                  = try(var.argo_rollouts.skip_crds, null)
  render_subchart_notes      = try(var.argo_rollouts.render_subchart_notes, null)
  disable_openapi_validation = try(var.argo_rollouts.disable_openapi_validation, null)
  wait                       = try(var.argo_rollouts.wait, false)
  wait_for_jobs              = try(var.argo_rollouts.wait_for_jobs, null)
  dependency_update          = try(var.argo_rollouts.dependency_update, null)
  replace                    = try(var.argo_rollouts.replace, null)
  lint                       = try(var.argo_rollouts.lint, null)

  postrender    = try(var.argo_rollouts.postrender, [])
  set           = try(var.argo_rollouts.set, [])
  set_sensitive = try(var.argo_rollouts.set_sensitive, [])

  tags = var.tags

  depends_on = [kubectl_manifest.aws_node_template]
}

################################################################################
# ArgoCD
################################################################################
module "argocd" {
  create = var.enable_argocd
  source = "./modules/blueprints-addon"

  name             = try(var.argocd.name, "argo-cd")
  description      = try(var.argocd.description, "A Helm chart to install the ArgoCD")
  namespace        = try(var.argocd.namespace, "argo-cd")
  create_namespace = try(var.argocd.create_namespace, true)
  chart            = try(var.argocd.chart, "argo-cd")
  chart_version    = try(var.argocd.chart_version, "5.53.14")
  repository       = try(var.argocd.repository, "https://argoproj.github.io/argo-helm")
  values           = try(var.argocd.values, [])

  timeout                    = try(var.argocd.timeout, null)
  repository_key_file        = try(var.argocd.repository_key_file, null)
  repository_cert_file       = try(var.argocd.repository_cert_file, null)
  repository_ca_file         = try(var.argocd.repository_ca_file, null)
  repository_username        = try(var.argocd.repository_username, null)
  repository_password        = try(var.argocd.repository_password, null)
  devel                      = try(var.argocd.devel, null)
  verify                     = try(var.argocd.verify, null)
  keyring                    = try(var.argocd.keyring, null)
  disable_webhooks           = try(var.argocd.disable_webhooks, null)
  reuse_values               = try(var.argocd.reuse_values, null)
  reset_values               = try(var.argocd.reset_values, null)
  force_update               = try(var.argocd.force_update, null)
  recreate_pods              = try(var.argocd.recreate_pods, null)
  cleanup_on_fail            = try(var.argocd.cleanup_on_fail, null)
  max_history                = try(var.argocd.max_history, null)
  atomic                     = try(var.argocd.atomic, null)
  skip_crds                  = try(var.argocd.skip_crds, null)
  render_subchart_notes      = try(var.argocd.render_subchart_notes, null)
  disable_openapi_validation = try(var.argocd.disable_openapi_validation, null)
  wait                       = try(var.argocd.wait, false)
  wait_for_jobs              = try(var.argocd.wait_for_jobs, null)
  dependency_update          = try(var.argocd.dependency_update, null)
  replace                    = try(var.argocd.replace, null)
  lint                       = try(var.argocd.lint, null)

  postrender    = try(var.argocd.postrender, [])
  set           = try(var.argocd.set, [])
  set_sensitive = try(var.argocd.set_sensitive, [])

  tags = var.tags

  depends_on = [kubectl_manifest.aws_node_template]
}

################################################################################
# AWS EFS CSI DRIVER
################################################################################

locals {
  aws_efs_csi_driver_controller_service_account = try(var.aws_efs_csi_driver.controller_service_account_name, "efs-csi-controller-sa")
  aws_efs_csi_driver_node_service_account       = try(var.aws_efs_csi_driver.node_service_account_name, "efs-csi-node-sa")
  aws_efs_csi_driver_namespace                  = try(var.aws_efs_csi_driver.namespace, "kube-system")
  efs_arns = lookup(var.aws_efs_csi_driver, "efs_arns",
    ["arn:${local.partition}:elasticfilesystem:${local.region}:${local.account_id}:file-system/*"],
  )
  efs_access_point_arns = lookup(var.aws_efs_csi_driver, "efs_access_point_arns",
    ["arn:${local.partition}:elasticfilesystem:${local.region}:${local.account_id}:access-point/*"]
  )
}

module "aws_efs_csi_driver" {
  source = "./modules/blueprints-addon"
  create = var.enable_aws_efs_csi_driver

  # https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/charts/aws-efs-csi-driver
  name             = try(var.aws_efs_csi_driver.name, "aws-efs-csi-driver")
  description      = try(var.aws_efs_csi_driver.description, "A Helm chart to deploy aws-efs-csi-driver")
  namespace        = local.aws_efs_csi_driver_namespace
  create_namespace = try(var.aws_efs_csi_driver.create_namespace, false)
  chart            = try(var.aws_efs_csi_driver.chart, "aws-efs-csi-driver")
  chart_version    = try(var.aws_efs_csi_driver.chart_version, "2.4.8")
  repository       = try(var.aws_efs_csi_driver.repository, "https://kubernetes-sigs.github.io/aws-efs-csi-driver/")
  values           = try(var.aws_efs_csi_driver.values, [])

  timeout                    = try(var.aws_efs_csi_driver.timeout, null)
  repository_key_file        = try(var.aws_efs_csi_driver.repository_key_file, null)
  repository_cert_file       = try(var.aws_efs_csi_driver.repository_cert_file, null)
  repository_ca_file         = try(var.aws_efs_csi_driver.repository_ca_file, null)
  repository_username        = try(var.aws_efs_csi_driver.repository_username, null)
  repository_password        = try(var.aws_efs_csi_driver.repository_password, null)
  devel                      = try(var.aws_efs_csi_driver.devel, null)
  verify                     = try(var.aws_efs_csi_driver.verify, null)
  keyring                    = try(var.aws_efs_csi_driver.keyring, null)
  disable_webhooks           = try(var.aws_efs_csi_driver.disable_webhooks, null)
  reuse_values               = try(var.aws_efs_csi_driver.reuse_values, null)
  reset_values               = try(var.aws_efs_csi_driver.reset_values, null)
  force_update               = try(var.aws_efs_csi_driver.force_update, null)
  recreate_pods              = try(var.aws_efs_csi_driver.recreate_pods, null)
  cleanup_on_fail            = try(var.aws_efs_csi_driver.cleanup_on_fail, null)
  max_history                = try(var.aws_efs_csi_driver.max_history, null)
  atomic                     = try(var.aws_efs_csi_driver.atomic, null)
  skip_crds                  = try(var.aws_efs_csi_driver.skip_crds, null)
  render_subchart_notes      = try(var.aws_efs_csi_driver.render_subchart_notes, null)
  disable_openapi_validation = try(var.aws_efs_csi_driver.disable_openapi_validation, null)
  wait                       = try(var.aws_efs_csi_driver.wait, false)
  wait_for_jobs              = try(var.aws_efs_csi_driver.wait_for_jobs, null)
  dependency_update          = try(var.aws_efs_csi_driver.dependency_update, null)
  replace                    = try(var.aws_efs_csi_driver.replace, null)
  lint                       = try(var.aws_efs_csi_driver.lint, null)

  postrender = try(var.aws_efs_csi_driver.postrender, [])
  set = concat([
    {
      name  = "controller.serviceAccount.name"
      value = local.aws_efs_csi_driver_controller_service_account
    },
    {
      name  = "node.serviceAccount.name"
      value = local.aws_efs_csi_driver_node_service_account
    }],
    try(var.aws_efs_csi_driver.set, [])
  )
  set_sensitive = try(var.aws_efs_csi_driver.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names = [
    "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn",
    "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  ]
  create_role                   = try(var.aws_efs_csi_driver.create_role, true)
  role_name                     = try(var.aws_efs_csi_driver.role_name, "AmazonEFSCSIDriverRole")
  role_name_use_prefix          = try(var.aws_efs_csi_driver.role_name_use_prefix, true)
  role_path                     = try(var.aws_efs_csi_driver.role_path, "/")
  role_permissions_boundary_arn = lookup(var.aws_efs_csi_driver, "role_permissions_boundary_arn", null)
  role_description              = try(var.aws_efs_csi_driver.role_description, "IRSA for aws-efs-csi-driver project")
  role_policies                 = lookup(var.aws_efs_csi_driver, "role_policies", {})

  policy_statements      = lookup(var.aws_efs_csi_driver, "policy_statements", [])
  policy_name            = try(var.aws_efs_csi_driver.policy_name, "AmazonEFSCSIDriverPolicy")
  policy_name_use_prefix = try(var.aws_efs_csi_driver.policy_name_use_prefix, true)
  policy_path            = try(var.aws_efs_csi_driver.policy_path, null)
  policy_description     = try(var.aws_efs_csi_driver.policy_description, "IAM Policy for AWS EFS CSI Driver")
  policy_document        = try(var.aws_efs_csi_driver.policy_document, "")

  oidc_providers = {
    controller = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.aws_efs_csi_driver_controller_service_account
    }
    node = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.aws_efs_csi_driver_node_service_account
    }
  }

  tags = var.tags
}
