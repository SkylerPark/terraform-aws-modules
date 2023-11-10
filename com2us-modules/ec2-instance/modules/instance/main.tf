locals {
  # ami = {
  #   "rocky8" = {
  #     "v1" = {
  #       "ami_id"      = try(data.aws_ami_ids.rocky8_v1.ids[0], "")
  #       "snapshot_id" = try(data.aws_ebs_snapshot_ids.rocky8_v1_swap.ids[0], "")
  #     }
  #     "v2" = {
  #       "ami_id"      = try(data.aws_ami_ids.rocky8_v2.ids[0], "")
  #       "snapshot_id" = try(data.aws_ebs_snapshot_ids.rocky8_v2_swap.ids[0], "")
  #     }
  #     "v3" = {
  #       "ami_id" = try(data.aws_ami_ids.rocky8_v3.ids[0], "")
  #     }
  #   }
  #   "centos7" = {
  #     "v1" = {
  #       "ami_id"      = try(data.aws_ami_ids.centos7_v1.ids[0], "")
  #       "snapshot_id" = try(data.aws_ebs_snapshot_ids.centos7_v1_swap.ids[0], "")
  #     }
  #     "v2" = {
  #       "ami_id" = try(data.aws_ami_ids.centos7_v2.ids[0], "")
  #     }
  #   }
  # }
}

resource "aws_instance" "this" {
  ami                         = var.ami == null && var.os != null ? data.aws_ami_ids.this[0].ids[0] : var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
  monitoring                  = var.monitoring
  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      throughput            = lookup(root_block_device.value, "throughput", null)
      tags                  = merge({ Name = "${var.instance_name}" }, var.tags)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      device_name           = lookup(ebs_block_device.value, "device_name", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", try(ebs_block_device.value["os_snapshot_id"], false) ? data.aws_ebs_snapshot_ids.this[0].ids[0] : null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      tags                  = merge({ Name = "${var.instance_name}-${ebs_block_device.value.disk_name}" }, var.tags)
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
    ignore_changes = [
      subnet_id, ami
    ]
  }

  tags = merge(
    var.tags,
    {
      Name = var.instance_name
    }
  )
  volume_tags = var.enable_volume_tags ? var.volume_tags : null
}

resource "aws_ebs_volume" "this" {
  for_each          = { for disk in var.attachment_ebs_block_device : disk.disk_name => disk }
  availability_zone = aws_instance.this.availability_zone
  encrypted         = try(each.value.encrypted, null)
  final_snapshot    = try(each.value.final_snapshot, false)
  iops              = try(each.value.iops, null)
  size              = try(each.value.volume_size, null)
  snapshot_id       = lookup(each.value, "snapshot_id", try(each.value.os_snapshot_id, false) ? data.aws_ebs_snapshot_ids.this[0].ids[0] : null)
  type              = try(each.value.volume_type, null)
  throughput        = try(each.value.throughput, null)
  kms_key_id        = try(each.value.kms_key_id, null)
  tags = merge(
    var.tags,
    {
      Name = "${var.instance_name}-${each.key}"
    }
  )

  depends_on = [
    aws_instance.this
  ]
}

resource "aws_volume_attachment" "this" {
  for_each    = { for disk in var.attachment_ebs_block_device : disk.disk_name => disk }
  device_name = each.value.device_name
  instance_id = aws_instance.this.id
  volume_id   = aws_ebs_volume.this[each.key].id
}

module "instance_eip" {
  source   = "../../../vpc/modules/eip"
  count    = var.create_eip ? 1 : 0
  instance = aws_instance.this.id
  name     = var.instance_name
  tags     = var.eip_tags
}

# resource "aws_network_interface" "this" {
#   count = 
#   subnet_id       = var.subnet_id
#   security_groups = var.vpc_security_group_ids
# }
