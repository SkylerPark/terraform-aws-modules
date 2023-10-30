data "aws_subnets" "this" {
  for_each = var.vpc_id != null ? toset(var.availability_zones) : toset([])
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["*-${var.subnet_name}-*"]
  }

  filter {
    name   = "availability-zone"
    values = ["${each.value}"]
  }
}

locals {
  subnets = flatten([
    for k, v in data.aws_subnets.this : [
      for id in v.ids : {
        id = id
      }
    ]
  ])
}

data "aws_subnet" "this" {
  for_each = { for v in local.subnets : v.id => v }
  id       = each.value.id
}

data "aws_ami" "amazon_linux_2_arm" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-arm64-gp2"]
  }
}

data "aws_ami" "amazon_linux_2_x86" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86-gp2"]
  }
}
