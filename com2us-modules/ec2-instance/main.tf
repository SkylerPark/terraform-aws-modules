locals {
  num_of_instances = merge(
    var.instances,
    { for num in var.default_instance : num => {} }
  )
  instance = {
    for k, v in local.num_of_instances : "${var.hostname}-${k}" => v
  }
  filter_count = 50
  # filter_subnets = {
  #   for k, v in data.aws_subnet.this : v.availability_zone => flatten([concat(v.available_ip_address_count > local.filter_count ? [v.id] : [])])
  # }
  filter_subnets = [for subnet_id, subnet in data.aws_subnet.this : { (subnet.availability_zone) = subnet_id } if subnet.available_ip_address_count > local.filter_count]
  grouped_subnets = merge([
    for item in local.filter_subnets : {
      for key, value in item : key => [value]
    }
  ]...)
  filter_subnets_one_az    = [for k, v in local.grouped_subnets : v[0]]
  temp_security_group_ids  = [for tmp_sg in module.temp_security_group : tmp_sg.security_group_id]
  custom_security_group_id = var.create_security_group ? [module.security_group[0].security_group_id] : []
}

module "security_group" {
  source                                = "../security-group"
  count                                 = var.create_security_group ? 1 : 0
  name                                  = "${var.hostname}-sg"
  description                           = var.security_group_description != "" ? var.security_group_description : "${var.hostname} SG"
  vpc_id                                = var.vpc_id
  ingress_with_source_security_group_id = var.ingress_with_source_security_group_id
  ingress_with_cidr_blocks              = var.ingress_with_cidr_blocks
  ingress_with_ipv6_cidr_blocks         = var.ingress_with_ipv6_cidr_blocks
  egress_with_source_security_group_id  = var.egress_with_source_security_group_id
  egress_with_cidr_blocks               = var.egress_with_cidr_blocks
  egress_with_ipv6_cidr_blocks          = var.egress_with_ipv6_cidr_blocks
}

module "temp_security_group" {
  source                                = "../security-group"
  for_each                              = var.temp_security_groups
  name                                  = "${var.hostname}-sg-${each.key}"
  description                           = try(each.value.description, "${var.hostname} SG")
  vpc_id                                = var.vpc_id
  ingress_with_source_security_group_id = try(each.value.ingress_with_source_security_group_id, [])
  ingress_with_cidr_blocks              = try(each.value.ingress_with_cidr_blocks, [])
  ingress_with_ipv6_cidr_blocks         = try(each.value.ingress_with_ipv6_cidr_blocks, [])
  egress_with_source_security_group_id  = try(each.value.egress_with_source_security_group_id, [])
  egress_with_cidr_blocks               = try(each.value.egress_with_cidr_blocks, [])
  egress_with_ipv6_cidr_blocks          = try(each.value.egress_with_ipv6_cidr_blocks, [])
}

module "instance" {
  source        = "./modules/instance"
  for_each      = local.instance
  instance_name = each.key
  os            = try(each.value.os, var.os)
  os_version    = try(each.value.os_version, var.os_version)
  ami           = try(each.value.ami, var.ami)
  instance_type = try(each.value.instance_type, var.instance_type)
  # subnet_id     = try(each.value.subnet_id, var.subnets[(index(keys(local.instance), each.key)) % length(var.subnets)])
  subnet_id                   = try(each.value.subnet_id, length(var.subnets) > 0 ? var.subnets[(index(keys(local.instance), each.key)) % length(var.subnets)] : local.filter_subnets_one_az[(index(keys(local.instance), each.key)) % length(local.filter_subnets_one_az)])
  vpc_security_group_ids      = concat(try(each.value.security_group_ids, var.security_group_ids), local.temp_security_group_ids, local.custom_security_group_id)
  key_name                    = try(each.value.key_name, var.key_name)
  associate_public_ip_address = try(each.value.associate_public_ip_address, var.associate_public_ip_address)
  monitoring                  = try(each.value.monitoring, var.monitoring)
  root_block_device           = try(each.value.root_block_device, var.root_block_device)
  ebs_block_device            = try(each.value.ebs_block_device, var.ebs_block_device)
  attachment_ebs_block_device = try(each.value.attachment_ebs_block_device, var.attachment_ebs_block_device)
  enable_volume_tags          = var.enable_volume_tags
  volume_tags                 = var.volume_tags
  is_lb                       = try(each.value.is_lb, var.is_lb)
  create_eip                  = try(each.value.create_eip, var.create_eip)
  tags                        = merge(var.tags, var.instance_tags)
  eip_tags                    = merge(var.tags, var.eip_tags)
  metadata_options            = try(each.value.metadata_options, var.metadata_options)
}
