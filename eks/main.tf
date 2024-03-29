locals {
  cluster_name = coalesce(var.cluster_name, replace("${var.name}-cluster-${var.cluster_version}", ".", "-"))
  dns_suffix   = coalesce(var.cluster_iam_role_dns_suffix, data.aws_partition.current.dns_suffix)
}

################################################################################
# EKS Cluster
################################################################################

resource "aws_eks_cluster" "this" {
  name                      = local.cluster_name
  version                   = var.cluster_version
  enabled_cluster_log_types = var.cluster_enabled_log_types

  role_arn = var.iam_role_arn

  vpc_config {
    security_group_ids      = var.cluster_security_group_ids
    subnet_ids              = coalescelist(var.control_plane_subnet_ids, var.subnet_ids)
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  dynamic "encryption_config" {
    for_each = [var.cluster_encryption_config]

    content {
      provider {
        key_arn = encryption_config.value.provider_key_arn
      }
      resources = encryption_config.value.resources
    }
  }

  tags = merge(
    var.tags,
    var.cluster_tags,
  )

  timeouts {
    create = lookup(var.cluster_timeouts, "create", null)
    update = lookup(var.cluster_timeouts, "update", null)
    delete = lookup(var.cluster_timeouts, "delete", null)
  }
}

resource "aws_ec2_tag" "cluster_primary_security_group" {
  for_each = { for k, v in merge(var.tags, var.cluster_tags) :
    k => v if k != "Name" && var.create_cluster_primary_security_group_tags && v != null
  }

  resource_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  key         = each.key
  value       = each.value
}

resource "aws_security_group_rule" "cluster" {
  count                    = var.enable_secondary_subnet ? 1 : 0
  security_group_id        = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  type                     = "ingress"
  to_port                  = 0
  from_port                = 0
  protocol                 = "-1"
  source_security_group_id = var.secondary_security_group_id
}

################################################################################
# IRSA
################################################################################

data "tls_certificate" "this" {
  count = var.enable_irsa ? 1 : 0

  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  count = var.enable_irsa ? 1 : 0

  client_id_list  = distinct(compact(concat(["sts.${local.dns_suffix}"], var.openid_connect_audiences)))
  thumbprint_list = concat([data.tls_certificate.this[0].certificates[0].sha1_fingerprint], var.custom_oidc_thumbprints)
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(
    { Name = "${local.cluster_name}-irsa" },
    var.tags
  )
}

################################################################################
# EKS Addons
################################################################################

data "aws_eks_addon_version" "this" {
  for_each = { for k, v in var.cluster_addons : k => v }

  addon_name         = try(each.value.name, each.key)
  kubernetes_version = coalesce(var.cluster_version, aws_eks_cluster.this.version)
  most_recent        = try(each.value.most_recent, null)
}

locals {
  enable_aws_ebs_csi_driver = contains(keys(var.cluster_addons), "aws-ebs-csi-driver")
}

data "aws_iam_policy_document" "ebs_csi_driver" {
  count = local.enable_aws_ebs_csi_driver ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc_provider[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace("${aws_iam_openid_connect_provider.oidc_provider[0].arn}", "/^(.*provider/)/", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-*"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace("${aws_iam_openid_connect_provider.oidc_provider[0].arn}", "/^(.*provider/)/", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

locals {
  ebs_csi_driver_role_name            = try(var.aws_ebs_csi_driver.role_name, "AmazonEBSCSIDriverRole")
  ebs_csi_driver_role_name_use_prefix = try(var.aws_ebs_csi_driver.role_name_use_prefix, true)
  ebs_csi_driver_policy_arns          = concat(["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"], try(var.aws_ebs_csi_driver.policy_arns, []))
}

resource "aws_iam_role" "ebs_csi_driver" {
  count = local.enable_aws_ebs_csi_driver ? 1 : 0

  name        = local.ebs_csi_driver_role_name_use_prefix ? null : local.ebs_csi_driver_role_name
  name_prefix = local.ebs_csi_driver_role_name_use_prefix ? "${local.ebs_csi_driver_role_name}-" : null
  path        = try(var.aws_ebs_csi_driver.role_path, "/")
  description = try(var.aws_ebs_csi_driver.role_description, "IRSA for EBS")

  assume_role_policy    = data.aws_iam_policy_document.ebs_csi_driver[0].json
  max_session_duration  = try(var.aws_ebs_csi_driver.max_session_duration, null)
  permissions_boundary  = try(var.aws_ebs_csi_driver.role_permissions_boundary_arn, null)
  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  count = local.enable_aws_ebs_csi_driver ? length(local.ebs_csi_driver_policy_arns) : 0

  role       = aws_iam_role.ebs_csi_driver[0].name
  policy_arn = element(local.ebs_csi_driver_policy_arns, count.index)
}

resource "aws_eks_addon" "this" {
  for_each = { for k, v in var.cluster_addons : k => v }

  cluster_name = aws_eks_cluster.this.name
  addon_name   = try(each.value.name, each.key)

  addon_version               = coalesce(try(each.value.addon_version, null), data.aws_eks_addon_version.this[each.key].version)
  configuration_values        = try(each.value.configuration_values, null)
  preserve                    = try(each.value.preserve, null)
  resolve_conflicts_on_create = try(each.value.resolve_conflicts_on_create, "OVERWRITE")
  resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "PRESERVE")
  service_account_role_arn    = try(each.value.service_account_role_arn, each.key == "aws-ebs-csi-driver" ? try(aws_iam_role.ebs_csi_driver[0].arn, null) : null)

  timeouts {
    create = try(each.value.timeouts.create, var.cluster_addons_timeouts.create, null)
    update = try(each.value.timeouts.update, var.cluster_addons_timeouts.update, null)
    delete = try(each.value.timeouts.delete, var.cluster_addons_timeouts.delete, null)
  }

  depends_on = [
    module.eks_managed_node_group,
  ]

  tags = var.tags
}

locals {
  node_iam_role_arns_non_windows = distinct(
    compact(
      concat(
        [for group in module.eks_managed_node_group : group.iam_role_arn],
        var.aws_auth_node_iam_role_arns_non_windows,
      )
    )
  )

  fargate_profile_pod_execution_role_arns = distinct(
    compact(
      concat(
        [for group in module.fargate_profile : group.fargate_profile_pod_execution_role_arn],
        var.aws_auth_fargate_profile_pod_execution_role_arns,
      )
    )
  )

  aws_auth_configmap_data = {
    mapRoles = yamlencode(concat(
      [for role_arn in local.node_iam_role_arns_non_windows : {
        rolearn  = role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
        ]
        }
      ],
      [for role_arn in local.fargate_profile_pod_execution_role_arns : {
        rolearn  = role_arn
        username = "system:node:{{SessionName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
          "system:node-proxier",
        ]
        }
      ],
      var.aws_auth_roles
    ))
    mapUsers    = yamlencode(var.aws_auth_users)
    mapAccounts = yamlencode(var.aws_auth_accounts)
  }
}

resource "kubernetes_config_map" "this" {
  count = var.create_aws_auth_configmap ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  lifecycle {
    ignore_changes = [data, metadata[0].labels, metadata[0].annotations]
  }
}

resource "kubernetes_config_map_v1_data" "this" {
  count = var.manage_aws_auth_configmap ? 1 : 0

  force = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  depends_on = [
    # Required for instances where the configmap does not exist yet to avoid race condition
    kubernetes_config_map.this,
  ]
}

module "eks_cni_custom_network" {
  count             = var.enable_secondary_subnet ? 1 : 0
  source            = "./modules/eks-cni-custom-network"
  secondary_subnets = var.secondary_subnets
  security_group_id = var.secondary_security_group_id
  depends_on        = [aws_eks_cluster.this]
}
