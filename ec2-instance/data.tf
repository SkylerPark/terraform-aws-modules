data "aws_subnets" "this" {
  for_each = var.subnet_name != "" ? toset(var.availability_zones) : toset([])

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
