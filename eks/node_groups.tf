# resource "time_sleep" "this" {
#   create_duration = var.dataplane_wait_duration

#   triggers = {
#     cluster_name     = aws_eks_cluster.this.name
#     cluster_endpoint = aws_eks_cluster.this.endpoint
#     cluster_version  = aws_eks_cluster.this.version

#     cluster_certificate_authority_data = aws_eks_cluster.this.certificate_authority[0].data
#   }
# }

# ################################################################################
# # Node Security Group
# ################################################################################

# locals {
#   node_sg_name = coalesce(var.node_security_group_name, "${local.cluster_name}-node-sg")

#   node_security_group_rules = {
#     ingress_cluster_443 = {
#       description                   = "Cluster API to node groups"
#       protocol                      = "tcp"
#       from_port                     = 443
#       to_port                       = 443
#       type                          = "ingress"
#       source_cluster_security_group = true
#     }
#     ingress_cluster_kubelet = {
#       description                   = "Cluster API to node kubelets"
#       protocol                      = "tcp"
#       from_port                     = 10250
#       to_port                       = 10250
#       type                          = "ingress"
#       source_cluster_security_group = true
#     }
#     ingress_self_coredns_tcp = {
#       description = "Node to node CoreDNS"
#       protocol    = "tcp"
#       from_port   = 53
#       to_port     = 53
#       type        = "ingress"
#       self        = true
#     }
#     ingress_self_coredns_udp = {
#       description = "Node to node CoreDNS UDP"
#       protocol    = "udp"
#       from_port   = 53
#       to_port     = 53
#       type        = "ingress"
#       self        = true
#     }
#   }

#   node_security_group_recommended_rules = { for k, v in {
#     ingress_nodes_ephemeral = {
#       description = "Node to node ingress on ephemeral ports"
#       protocol    = "tcp"
#       from_port   = 1025
#       to_port     = 65535
#       type        = "ingress"
#       self        = true
#     }
#     # metrics-server
#     ingress_cluster_4443_webhook = {
#       description                   = "Cluster API to node 4443/tcp webhook"
#       protocol                      = "tcp"
#       from_port                     = 4443
#       to_port                       = 4443
#       type                          = "ingress"
#       source_cluster_security_group = true
#     }
#     # prometheus-adapter
#     ingress_cluster_6443_webhook = {
#       description                   = "Cluster API to node 6443/tcp webhook"
#       protocol                      = "tcp"
#       from_port                     = 6443
#       to_port                       = 6443
#       type                          = "ingress"
#       source_cluster_security_group = true
#     }
#     # Karpenter
#     ingress_cluster_8443_webhook = {
#       description                   = "Cluster API to node 8443/tcp webhook"
#       protocol                      = "tcp"
#       from_port                     = 8443
#       to_port                       = 8443
#       type                          = "ingress"
#       source_cluster_security_group = true
#     }
#     # ALB controller, NGINX
#     ingress_cluster_9443_webhook = {
#       description                   = "Cluster API to node 9443/tcp webhook"
#       protocol                      = "tcp"
#       from_port                     = 9443
#       to_port                       = 9443
#       type                          = "ingress"
#       source_cluster_security_group = true
#     }
#     egress_all = {
#       description = "Allow all egress"
#       protocol    = "-1"
#       from_port   = 0
#       to_port     = 0
#       type        = "egress"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   } : k => v }
# }

# resource "aws_security_group" "node" {
#   name        = local.node_sg_name
#   description = var.node_security_group_description
#   vpc_id      = var.vpc_id

#   tags = merge(
#     var.tags,
#     {
#       "Name"                                        = local.node_sg_name
#       "kubernetes.io/cluster/${local.cluster_name}" = "owned"
#     },
#     var.node_security_group_tags
#   )

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_security_group_rule" "node" {
#   for_each = { for k, v in merge(
#     local.node_security_group_rules,
#     local.node_security_group_recommended_rules,
#     var.node_security_group_additional_rules,
#   ) : k => v }

#   # Required
#   security_group_id = aws_security_group.node.id
#   protocol          = each.value.protocol
#   from_port         = each.value.from_port
#   to_port           = each.value.to_port
#   type              = each.value.type

#   # Optional
#   description              = lookup(each.value, "description", null)
#   cidr_blocks              = lookup(each.value, "cidr_blocks", null)
#   ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
#   prefix_list_ids          = lookup(each.value, "prefix_list_ids", [])
#   self                     = lookup(each.value, "self", null)
#   source_security_group_id = try(each.value.source_cluster_security_group, false) ? aws_security_group.cluster.id : lookup(each.value, "source_security_group_id", null)
# }

# module "eks_managed_node_group" {
#   source = "./modules/eks-managed-node-group"

# }
