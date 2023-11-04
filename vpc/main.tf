locals {
  vpc_name = var.vpc_name != "" ? var.vpc_name : "${var.name}-vpc-${data.aws_region.current.name}"
}

data "aws_region" "current" {}

resource "aws_vpc" "this" {
  count      = var.create_vpc ? 1 : 0
  cidr_block = var.cidr_block

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.instance_tenancy

  tags = merge(
    { "Name" = local.vpc_name },
    var.tags,
    var.vpc_tags,
  )
}

locals {
  subnets = flatten([
    for k, v in var.subnets : [
      for cidr in v.cidr_blocks : "${k}/${cidr}"
    ]
  ])
}

resource "aws_subnet" "this" {
  for_each = { for subnet in local.subnets : subnet => subnet }

  vpc_id                  = var.vpc_id != "" ? aws_vpc.this[0].id : vae.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = try(each.value.availability_zone, var.availability_zones[index(keys(local.subnets), each.key) % length(var.subnets)])
  map_public_ip_on_launch = try(each.value.map_public_ip_on_launch, false)

  tags = merge(
    { "Name" = try(each.value.name, format("%s-subnet-%s", var.name, var.availability_zone[index(keys(local.subnets), each.key) % length(var.subnets)])) },
    each.value.tags,
    var.subnet_tags,
  )
}
