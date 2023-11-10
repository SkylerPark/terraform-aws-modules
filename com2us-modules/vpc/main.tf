locals {
  create_vpc = var.vpc_id != null ? false : true
  vpc_id     = var.vpc_id != null ? var.vpc_id : module.vpc[0].id
}

module "vpc" {
  source = "./modules/vpc"
  count  = local.create_vpc ? 1 : 0

  name                = var.vpc_name != null ? var.vpc_name : "${var.name}-vpc"
  cidr_block          = var.use_ipam_pool ? null : var.cidr
  ipv4_ipam_pool_id   = var.ipv4_ipam_pool_id
  ipv4_netmask_length = var.ipv4_netmask_length

  assign_generated_ipv6_cidr_block = var.enable_ipv6 && !var.use_ipam_pool ? true : null
  ipv6_cidr_block                  = var.ipv6_cidr
  ipv6_ipam_pool_id                = var.ipv6_ipam_pool_id
  ipv6_netmask_length              = var.ipv6_netmask_length

  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(var.tags, var.vpc_tags)
}

module "internet_gateway" {
  source = "./modules/internet-gateway"
  count  = var.create_internet_gateway ? 1 : 0
  vpc_id = local.vpc_id
  name   = var.internet_gateway_name != null ? var.internet_gateway_name : "${var.name}-igw"
  tags   = merge(var.tags, var.internet_gateway_tags)
}

module "subnet" {
  source                          = "./modules/subnet"
  for_each                        = var.subnets
  vpc_id                          = local.vpc_id
  name                            = each.key
  cidr_block                      = each.value.cidr_block
  availability_zone               = each.value.availability_zone
  map_public_ip_on_launch         = try(each.value.map_public_ip_on_launch, false)
  assign_ipv6_address_on_creation = try(each.value.assign_ipv6_address_on_creation, false)
  ipv6_cidr_block                 = var.enable_ipv6 ? try(each.value.ipv6_cidr_block, null) : null

  tags = merge(var.tags, var.subnet_tags, try(each.value.tags, {}))
}

module "eip" {
  source   = "./modules/eip"
  for_each = var.nat_gateways
  name     = each.key
  tags     = merge(var.tags, var.eip_tags)
}

module "nat_gateway" {
  source        = "./modules/nat-gateway"
  for_each      = var.nat_gateways
  name          = each.key
  allocation_id = module.eip[each.key].id
  subnet_id     = module.subnet[each.value.public_subnet_name].id
  tags          = merge(var.tags, var.nat_gateway_tags, try(each.value.tags, {}))
}

module "route_table" {
  source           = "./modules/route-table"
  for_each         = var.route_tables
  vpc_id           = local.vpc_id
  name             = each.key
  propagating_vgws = try(each.value.propagating_vgws, [])
  routes = concat(
    try(each.value.routes, []),
    try(each.value.enable_internet_gateway, false) && var.create_internet_gateway ?
    [
      {
        cidr_block = "0.0.0.0/0"
        gateway_id = try(each.value.internet_gateway_id, module.internet_gateway[0].id)
      }
    ] :
    try(each.value.enable_nat_gateway, false) && length(var.nat_gateways) > 0 ?
    [
      {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = try(each.value.nat_gateway_id, module.nat_gateway[each.value.nat_gateway].id)
      }
    ] : []
  )
  tags = merge(var.tags, var.route_table_tags, try(each.value.tags, {}))
}

module "route_table_association" {
  source         = "./modules/route-table-association"
  for_each       = var.subnets
  subnet_id      = module.subnet[each.key].id
  route_table_id = module.route_table[each.value.route_table].id
}

data "aws_subnet" "this" {
  for_each = var.subnets
  id       = module.subnet[each.key].id
  depends_on = [
    module.subnet
  ]
}
