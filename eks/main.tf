################################################################################
# EKS Cluster
################################################################################

locals {
  cluster_name = coalesce(var.cluster_name, replace("${var.name}-cluster-${var.version}", ".", "-"))
}

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
    k => v if local.create && k != "Name" && var.create_cluster_primary_security_group_tags && v != null
  }

  resource_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  key         = each.key
  value       = each.value
}

################################################################################
# Cluster Security Group
################################################################################

# locals {
#   cluster_sg_name = coalesce(var.cluster_security_group_name, "${local.cluster_name}-sg")

#   cluster_security_group_rules = { for k, v in {
#     ingress_nodes_443 = {
#       description                = "Node groups to cluster API"
#       protocol                   = "tcp"
#       from_port                  = 443
#       to_port                    = 443
#       type                       = "ingress"
#       source_node_security_group = true
#     }
#   } : k => v }
# }

# resource "aws_security_group" "cluster" {
#   name        = local.cluster_sg_name
#   description = var.cluster_security_group_description
#   vpc_id      = var.vpc_id

#   tags = merge(
#     var.tags,
#     { "Name" = local.cluster_sg_name },
#     var.cluster_security_group_tags
#   )

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_security_group_rule" "cluster" {
#   for_each = { for k, v in merge(
#     local.cluster_security_group_rules,
#     var.cluster_security_group_additional_rules
#   ) : k => v }

#   security_group_id = aws_security_group.cluster.id
#   protocol          = each.value.protocol
#   from_port         = each.value.from_port
#   to_port           = each.value.to_port
#   type              = each.value.type

#   description              = lookup(each.value, "description", null)
#   cidr_blocks              = lookup(each.value, "cidr_blocks", null)
#   ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
#   prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
#   self                     = lookup(each.value, "self", null)
#   source_security_group_id = null
#   # source_security_group_id = try(each.value.source_node_security_group, false) ? aws_security_group.node.id : lookup(each.value, "source_security_group_id", null)
# }

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

resource "aws_eks_addon" "this" {
  for_each = { for k, v in var.cluster_addons : k => v }

  cluster_name = aws_eks_cluster.this.name
  addon_name   = try(each.value.name, each.key)

  addon_version            = coalesce(try(each.value.addon_version, null), data.aws_eks_addon_version.this[each.key].version)
  configuration_values     = try(each.value.configuration_values, null)
  preserve                 = try(each.value.preserve, null)
  resolve_conflicts        = try(each.value.resolve_conflicts, "OVERWRITE")
  service_account_role_arn = try(each.value.service_account_role_arn, null)

  timeouts {
    create = try(each.value.timeouts.create, var.cluster_addons_timeouts.create, null)
    update = try(each.value.timeouts.update, var.cluster_addons_timeouts.update, null)
    delete = try(each.value.timeouts.delete, var.cluster_addons_timeouts.delete, null)
  }

  # depends_on = [
  #   module.eks_managed_node_group,
  # ]

  tags = var.tags
}
