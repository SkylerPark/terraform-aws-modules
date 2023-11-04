locals {
  vpc_name = var.vpc_name != "" ? var.vpc_name : "${var.name}-vpc-${data.aws_region.current.name}"
  vpc_id   = var.vpc_id != "" ? aws_vpc.this[0].id : var.vpc_id
  igw_name = var.igw_name != "" ? var.igw_name : "${var.name}-igw-${data.aws_region.current.name}"
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

resource "aws_subnet" "this" {
  for_each = { for subnet in var.subnets : "${subnet.name}-${subnet.tier}/${subnet.availability_zone}/${subnet.cidr_block}" => subnet }

  vpc_id                  = local.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = try(each.value.map_public_ip_on_launch, false)

  tags = merge(
    { "Name" = "${each.value.name}-${each.value.tier}-subnet-${each.value.availability_zone}", "Tier" = "${each.value.tier}" },
    try(each.value.tags, {}),
    var.subnet_tags,
  )
}

resource "aws_internet_gateway" "this" {
  count = var.create_igw ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = local.igw_name },
    var.tags,
    var.igw_tags,
  )
}

locals {
  availability_zones = distinct([for subnet in var.subnets : subnet.availability_zone])
  nat_gateway_count  = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(local.availability_zones) : 0
}

resource "aws_eip" "this" {
  count = var.create_vpc && var.create_nat_gw ? local.nat_gateway_count : 0

  domain = "vpc"

  tags = merge(
    {
      "Name" = format(
        "${var.name}-natgw-%s",
        element(local.availability_zones, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_eip_tags,
  )

  depends_on = [aws_internet_gateway.this]
}

data "aws_subnets" "public" {
  count = var.create_nat_gw && local.nat_gateway_count > 0 ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  tags = {
    Tier = "public"
  }

  depends_on = [aws_subnet.this]
}

resource "aws_nat_gateway" "this" {
  count = var.create_vpc && var.create_nat_gw ? local.nat_gateway_count : 0

  allocation_id = element(
    aws_eip.this,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    data.aws_subnets.public[0].ids,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    {
      "Name" = format(
        "${var.name}-natgw-%s",
        element(local.availability_zones, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_gw_tags,
  )

  depends_on = [aws_internet_gateway.this]
}
