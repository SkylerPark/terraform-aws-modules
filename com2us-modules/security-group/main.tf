module "security_group" {
  source      = "./modules/security-group"
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id
  tags        = var.tags
}

module "ingress_with_source_security_group_id" {
  source                   = "./modules/security-group-rule"
  for_each                 = { for rule in var.ingress_with_source_security_group_id : format("%s_%s_%d_%d_%s", "ingress", rule.protocol, rule.from_port, rule.to_port, rule.source_security_group_id) => rule }
  security_group_id        = module.security_group.id
  type                     = "ingress"
  protocol                 = each.value.protocol
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  source_security_group_id = each.value.source_security_group_id
  description              = try(each.value.description, null)
}

module "egress_with_source_security_group_id" {
  source                   = "./modules/security-group-rule"
  for_each                 = { for rule in var.egress_with_source_security_group_id : format("%s_%s_%d_%d_%s", "egress", rule.protocol, rule.from_port, rule.to_port, rule.source_security_group_id) => rule }
  security_group_id        = module.security_group.id
  type                     = "egress"
  protocol                 = each.value.protocol
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  source_security_group_id = each.value.source_security_group_id
  description              = try(each.value.description, null)
}

module "ingress_with_cidr_blocks" {
  source            = "./modules/security-group-rule"
  for_each          = { for rule in var.ingress_with_cidr_blocks : format("%s_%s_%d_%d_%s", "ingress", rule.protocol, rule.from_port, rule.to_port, replace(rule.cidr_blocks, ",", "_")) => rule }
  security_group_id = module.security_group.id
  type              = "ingress"
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_blocks       = split(",", each.value.cidr_blocks)
  description       = try(each.value.description, null)
}

module "egress_with_cidr_blocks" {
  source            = "./modules/security-group-rule"
  for_each          = { for rule in var.egress_with_cidr_blocks : format("%s_%s_%d_%d_%s", "egress", rule.protocol, rule.from_port, rule.to_port, replace(rule.cidr_blocks, ",", "_")) => rule }
  security_group_id = module.security_group.id
  type              = "egress"
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_blocks       = split(",", each.value.cidr_blocks)
  description       = try(each.value.description, null)
}

module "ingress_with_ipv6_cidr_blocks" {
  source            = "./modules/security-group-rule"
  for_each          = { for rule in var.ingress_with_ipv6_cidr_blocks : format("%s_%s_%d_%d_%s", "ingress", rule.protocol, rule.from_port, rule.to_port, replace(rule.ipv6_cidr_blocks, ",", "_")) => rule }
  security_group_id = module.security_group.id
  type              = "ingress"
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ipv6_cidr_blocks  = split(",", each.value.ipv6_cidr_blocks)
  description       = try(each.value.description, null)
}

module "egress_with_ipv6_cidr_blocks" {
  source            = "./modules/security-group-rule"
  for_each          = { for rule in var.egress_with_ipv6_cidr_blocks : format("%s_%s_%d_%d_%s", "egress", rule.protocol, rule.from_port, rule.to_port, replace(rule.ipv6_cidr_blocks, ",", "_")) => rule }
  security_group_id = module.security_group.id
  type              = "egress"
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ipv6_cidr_blocks  = split(",", each.value.ipv6_cidr_blocks)
  description       = try(each.value.description, null)
}

