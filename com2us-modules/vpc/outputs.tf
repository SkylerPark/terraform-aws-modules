output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(module.vpc[0].id, "")
}

output "vpc_name" {
  description = "The Name of the VPC"
  value       = try("${module.vpc[0].name}", "")
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = try(module.vpc[0].cidr_block, "")
}

output "subnets" {
  description = "The All resource of the Subnet"
  value = {
    for subnet in module.subnet : subnet.name => {
      id                         = subnet.id
      cidr_block                 = subnet.cidr_block
      availability_zone          = subnet.availability_zone
      available_ip_address_count = try(data.aws_subnet.this[subnet.name].available_ip_address_count, "")
    }
  }
}

output "nat_gateways" {
  description = "The All resource of the Nat gateway"
  value = {
    for nat in module.nat_gateway : nat.name => {
      id        = nat.id
      public_ip = nat.public_ip
    }
  }
}

output "internet_gateways" {
  description = "The All resource of the VPN gateway"
  value       = { try("${module.internet_gateway[0].name}", "") = try(module.internet_gateway[0].id, "") }
}
