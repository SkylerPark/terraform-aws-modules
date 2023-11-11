resource "aws_security_group" "this" {
  name        = !var.use_name_prefix ? var.name : null
  name_prefix = var.use_name_prefix ? "${ver.name}-" : null
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_vpc_security_group_ingress_rule" "ingress_with_cidr_ipv4" {
  for_each = { for rule in var.ingress_with_cidr_blocks : format("%s_%s_%d_%d_%s", "ingress", rule.ip_protocol, rule.from_port, rule.to_port, rule.cidr_ipv4) => rule }

  security_group_id = aws_security_group.this.id
  description       = try(each.value.description, "")

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv4   = each.value.cidr_ipv4
}

resource "aws_vpc_security_group_egress_rule" "egress_with_cidr_ipv4" {
  for_each = { for rule in var.egress_with_cidr_blocks : format("%s_%s_%d_%d_%s", "egress", rule.ip_protocol, rule.from_port, rule.to_port, rule.cidr_ipv4) => rule }

  security_group_id = aws_security_group.this.id
  description       = try(each.value.description, "")

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv4   = each.value.cidr_ipv4
}

resource "aws_vpc_security_group_ingress_rule" "ingress_with_security_group_id" {
  for_each = { for rule in var.ingress_with_source_security_group_id : format("%s_%s_%d_%d_%s", "ingress", rule.ip_protocol, rule.from_port, rule.to_port, rule.referenced_security_group_id) => rule }

  security_group_id = aws_security_group.this.id
  description       = try(each.value.description, "")

  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.ip_protocol
  referenced_security_group_id = each.value.referenced_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "egress_with_security_group_id" {
  for_each = { for rule in var.egress_with_security_group_id : format("%s_%s_%d_%d_%s", "egress", rule.ip_protocol, rule.from_port, rule.to_port, rule.referenced_security_group_id) => rule }

  security_group_id = aws_security_group.this.id
  description       = try(each.value.description, "")

  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.ip_protocol
  referenced_security_group_id = each.value.referenced_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_with_cidr_ipv6" {
  for_each = { for rule in var.ingress_with_cidr_ipv6 : format("%s_%s_%d_%d_%s", "ingress", rule.ip_protocol, rule.from_port, rule.to_port, rule.cidr_ipv6) => rule }

  security_group_id = aws_security_group.this.id
  description       = try(each.value.description, "")

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv6   = each.value.cidr_ipv6
}

resource "aws_vpc_security_group_egress_rule" "egress_with_cidr_ipv6" {
  for_each = { for rule in var.egress_with_cidr_ipv6 : format("%s_%s_%d_%d_%s", "egress", rule.ip_protocol, rule.from_port, rule.to_port, rule.cidr_ipv6) => rule }

  security_group_id = aws_security_group.this.id
  description       = try(each.value.description, "")

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv6   = each.value.cidr_ipv6
}
