locals {
  filter_count   = 30
  filter_subnets = [for subnet_id, subnet in data.aws_subnet.this : { (subnet.availability_zone) = subnet_id } if subnet.available_ip_address_count > local.filter_count]
  grouped_subnets = merge([
    for item in local.filter_subnets : {
      for key, value in item : key => [value]
    }
  ]...)
  filter_subnets_one_az = [for k, v in local.grouped_subnets : v[0]]

  is_t_instance_type = replace(var.instance_type, "/^t(2|3|3a|4g){1}\\..*$/", "1") == "1" ? true : false

  ami = try(coalesce(var.ami, try(nonsensitive(data.aws_ssm_parameter.this[0].value), null)), null)
}

data "aws_ssm_parameter" "this" {
  count = var.ami == "" ? 1 : 0

  name = var.ami_ssm_parameter
}

resource "aws_instance" "this" {
  for_each = toset(var.num_instances)

  ami           = local.ami
  instance_type = var.instance_type

  availability_zone      = var.availability_zones[index(keys(var.num_instances), each.key) % length(var.availability_zones)]
  subnet_id              = var.subnet_name == "" ? var.subnet_ids[index(keys(var.num_instances), each.key) % length(var.subnet_ids)] : local.filter_subnets_one_az[index(keys(var.num_instances), each.key) % length(local.filter_subnets_one_az)]
  vpc_security_group_ids = var.vpc_security_group_ids

  key_name             = var.key_name
  monitoring           = var.monitoring
  iam_instance_profile = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile

  associate_public_ip_address = var.associate_public_ip_address

  dynamic "root_block_device" {
    for_each = var.root_block_device

    content {
      delete_on_termination = try(root_block_device.value.delete_on_termination, null)
      encrypted             = try(root_block_device.value.encrypted, null)
      iops                  = try(root_block_device.value.iops, null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = try(root_block_device.value.volume_size, null)
      volume_type           = try(root_block_device.value.volume_type, null)
      throughput            = try(root_block_device.value.throughput, null)
      tags                  = try(root_block_device.value.tags, { Name = "${each.key}-os" })
    }
  }

  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [var.metadata_options] : []

    content {
      http_endpoint               = try(metadata_options.value.http_endpoint, "enabled")
      http_tokens                 = try(metadata_options.value.http_tokens, "optional")
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, 1)
      instance_metadata_tags      = try(metadata_options.value.instance_metadata_tags, null)
    }
  }

  lifecycle {
    ignore_changes = [subnet_id, availability_zone, ami]
  }

  tags = merge(
    var.tags,
    var.instance_tags,
    {
      Name = "${var.name}-${each.key}"
    }
  )
  volume_tags = var.enable_volume_tags ? var.volume_tags : null
}

locals {
  ebs_block_device = flatten([
    for num in var.num_instances : [
      for ebs in var.ebs_block_device : merge(ebs, { name = "${var.name}-${num}-${ebs.name}", instance_id = aws_instance.this[num].id, availability_zone = aws_instance.this[num].availability_zone })
    ]
  ])
}

resource "aws_ebs_volume" "this" {
  for_each          = { for ebs_block in local.ebs_block_device : ebs_block.name => ebs_block }
  availability_zone = each.value.availability_zone
  encrypted         = try(each.value.encrypted, null)
  final_snapshot    = try(each.value.final_snapshot, false)
  iops              = try(each.value.iops, null)
  size              = try(each.value.volume_size, null)
  snapshot_id       = try(each.value.snapshot_id, null)
  type              = try(each.value.volume_type, null)
  throughput        = try(each.value.throughput, null)
  kms_key_id        = try(each.value.kms_key_id, null)
  tags = merge(
    { Name = "${eash.key}" },
    var.tags,
    var.ebs_tags
  )

  depends_on = [
    aws_instance.this
  ]
}

resource "aws_volume_attachment" "this" {
  for_each    = { for ebs_block in local.ebs_block_device : ebs_block.name => ebs_block }
  device_name = each.value.device_name
  instance_id = each.value.instance_id
  volume_id   = aws_ebs_volume.this[each.key].id
}

resource "aws_eip" "this" {
  for_each = toset(var.num_instances)
  instance = aws_instance.this[each.key].id
  tags = merge(
    { Name = "${var.name}-${each.key}" },
    var.tags,
    var.eip_tags
  )
}
