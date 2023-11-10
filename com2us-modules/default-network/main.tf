module "vpc" {
  source = "./modules/vpc"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "subnet" {
  source            = "./modules/subnet"
  count             = var.create_subnet ? length(data.aws_availability_zones.available.names) : 0
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

module "internet_gateway" {
  source = "../network/modules/internet-gateway"
  count  = var.create_internet_gateway ? 1 : 0
  name   = var.internet_gateway_name == null ? null : var.internet_gateway_name
  vpc_id = module.vpc.vpc_id
  tags   = merge(var.tags, var.internet_gateway_tags)
}

module "route_table" {
  source                               = "./modules/route-table"
  default_route_table_id               = module.vpc.default_route_table_id
  default_route_table_propagating_vgws = var.default_route_table_propagating_vgws
  default_route_table_routes           = concat(var.default_route_table_routes, (var.create_internet_gateway ? [{ cidr_block = "0.0.0.0/0", gateway_id = module.internet_gateway[0].id }] : []))
}
