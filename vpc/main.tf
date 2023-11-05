locals {
  vpc_name = var.vpc_name != "" ? var.vpc_name : "${var.name}-vpc-${data.aws_region.current.name}"
  vpc_id   = var.vpc_id != "" ? var.vpc_id : aws_vpc.this[0].id
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
    var.tags
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
  nat_gateway_count  = var.create_vpc && var.create_nat_gw ? var.single_nat_gateway ? [local.availability_zones[0]] : var.one_nat_gateway_per_az ? local.availability_zones : [] : []
}

resource "aws_eip" "this" {
  for_each = toset(local.nat_gateway_count)

  domain = "vpc"

  tags = merge(
    {
      "Name" = "${var.name}-natgw-${each.key}"
    },
    var.tags,
    var.nat_eip_tags,
  )

  depends_on = [aws_internet_gateway.this]
}

data "aws_subnets" "public" {
  for_each = toset(local.nat_gateway_count)

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  filter {
    name   = "availability-zone"
    values = ["${each.key}"]
  }

  tags = {
    Tier = "public"
  }
}
resource "aws_nat_gateway" "this" {
  for_each = toset(local.nat_gateway_count)

  allocation_id = aws_eip.this[each.key].id

  subnet_id = data.aws_subnets.public[each.key].ids[0]

  tags = merge(
    {
      "Name" = "${var.name}-natgw-${each.key}"
    },
    var.tags,
    var.nat_gw_tags,
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "this" {
  for_each         = { for route in var.route_tables : route.name => route }
  vpc_id           = local.vpc_id
  propagating_vgws = try(each.value.propagating_vgws, [])

  dynamic "route" {
    for_each = concat(
      try(each.value.enable_igw, false) ? [
        {
          cidr_block = "0.0.0.0/0",
          gateway_id = try(each.value.igw_id, aws_internet_gateway.this[0].id)
        }
      ] :
      try(each.value.enable_nat_gw, false) ? [
        {
          cidr_block     = "0.0.0.0/0"
          nat_gateway_id = try(each.value.nat_gw_id, aws_nat_gateway.this[each.value.nat_gw_az].id)
        }
      ] :
    [], try(each.value.routes, []))
    content {
      cidr_block                 = try(route.value.cidr_block, null)
      ipv6_cidr_block            = try(route.value.ipv6_cidr_block, null)
      destination_prefix_list_id = try(route.value.destination_prefix_list_id, null)
      carrier_gateway_id         = try(route.value.destination_prefix_list_id, null)
      core_network_arn           = try(route.value.core_network_arn, null)
      egress_only_gateway_id     = try(route.value.egress_only_gateway_id, null)
      gateway_id                 = try(route.value.gateway_id, null)
      local_gateway_id           = try(route.value.local_gateway_id, null)
      nat_gateway_id             = try(route.value.nat_gateway_id, null)
      transit_gateway_id         = try(route.value.transit_gateway_id, null)
      vpc_endpoint_id            = try(route.value.vpc_endpoint_id, null)
      vpc_peering_connection_id  = try(route.value.vpc_peering_connection_id, null)
    }
  }

  tags = merge(
    { "Name" = each.key },
    try(each.value.tags, {}),
    var.route_table_tags,
    var.tags
  )
}

locals {
  route_table_associations = [
    for subnet in var.subnets : {
      name           = "${subnet.name}-${subnet.tier}/${subnet.availability_zone}/${subnet.cidr_block}/${subnet.route_table_name}"
      subnet_id      = aws_subnet.this["${subnet.name}-${subnet.tier}/${subnet.availability_zone}/${subnet.cidr_block}"].id
      route_table_id = try(aws_route_table.this[try(subnet.route_table_name, "${subnet.name}-${subnet.tier}-rt-01")].id, null)
    }
  ]
}

resource "aws_route_table_association" "this" {
  for_each       = { for table_association in local.route_table_associations : table_association.name => table_association }
  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}
