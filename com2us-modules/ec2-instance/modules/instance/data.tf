data "aws_ec2_instance_type" "this" {
  instance_type = var.instance_type
}

# data "aws_ami_ids" "rocky8_v1" {
#   owners = ["929083391419"]

#   filter {
#     name   = "name"
#     values = ["iep-rocky8-swap-v1"]
#   }
# }

# data "aws_ebs_snapshot_ids" "rocky8_v1_swap" {
#   owners = ["929083391419"]

#   filter {
#     name   = "volume-size"
#     values = ["10"]
#   }

#   filter {
#     name   = "tag:Name"
#     values = ["iep-rocky8-swap-v1"]
#   }
# }

# data "aws_ami_ids" "centos7_v1" {
#   owners = ["929083391419"]

#   filter {
#     name   = "name"
#     values = ["iep-centos7-swap-v1"]
#   }
# }

# data "aws_ebs_snapshot_ids" "centos7_v1_swap" {
#   owners = ["929083391419"]

#   filter {
#     name   = "volume-size"
#     values = ["10"]
#   }

#   filter {
#     name   = "tag:Name"
#     values = ["iep-centos7-swap-v1"]
#   }
# }

# data "aws_ami_ids" "rocky8_v2" {
#   owners = ["929083391419"]

#   filter {
#     name   = "name"
#     values = ["iep-rocky8-swap-v2"]
#   }
# }

data "aws_ebs_snapshot_ids" "this" {
  count  = var.os != null && var.os_version != "v3" ? 1 : 0
  owners = ["929083391419"]

  filter {
    name   = "volume-size"
    values = ["10"]
  }

  filter {
    name   = "tag:Name"
    values = ["iep-${var.os}-swap-${var.os_version}"]
  }
}

# data "aws_ami_ids" "rocky8_v3" {
#   owners = ["929083391419"]

#   filter {
#     name   = "tag:Name"
#     values = ["iep-rocky8-v3"]
#   }
# }

# data "aws_ami_ids" "centos7_v2" {
#   owners = ["929083391419"]

#   filter {
#     name   = "tag:Name"
#     values = ["iep-centos7-v2"]
#   }
# }

data "aws_ami_ids" "this" {
  count  = var.os != null ? 1 : 0
  owners = ["929083391419"]

  filter {
    name   = "tag:Name"
    values = ["iep-${var.os}-${var.os_version}"]
  }
}
