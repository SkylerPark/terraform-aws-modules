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
      for cidr in v.cidr_blocks : {
        name                    = try(v.name, format("%s-%s-subnet-%s", var.name, k, var.availability_zones[index(keys(local.subnets), each.key) % length(var.availability_zones)]))
        key                     = "${k}/${cidr}"
        cidr_block              = cidr
        availability_zone       = try(v.availability_zone, var.availability_zones[index(keys(local.subnets), each.key) % length(var.availability_zones)])
        map_public_ip_on_launch = try(v.map_public_ip_on_launch, false)
      }
    ]
  ])
}

resource "aws_subnet" "this" {
  for_each = { for subnet in local.subnets : subnet.key => subnet }

  vpc_id                  = var.vpc_id != "" ? aws_vpc.this[0].id : var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = merge(
    { "Name" = each.value.name },
    try(each.value.tags, {}),
    var.subnet_tags,
  )
}
