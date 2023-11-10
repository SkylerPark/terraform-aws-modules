################################################################################
# VPC
################################################################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.this[0].id, null)
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = try(aws_vpc.this[0].arn, null)
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = try(aws_vpc.this[0].cidr_block, null)
}

################################################################################
# Internet Gateway
################################################################################

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = try(aws_internet_gateway.this[0].id, null)
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = try(aws_internet_gateway.this[0].arn, null)
}

################################################################################
# Internet Gateway
################################################################################

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = [for eip in aws_eip.this : eip.id]
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = [for eip in aws_eip.this : eip.public_ip]
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = [for natgw in aws_nat_gateway.this : natgw.id]
}

################################################################################
# Subnets And RouteTable
################################################################################

output "subnets" {
  description = "The Info of the Subnet All Resource"
  value = {
    for subnet in var.subnets : "${subnet.name}-${subnet.tier}-subnet-${subnet.availability_zone}" => {
      id                = aws_subnet.this["${subnet.name}-${subnet.tier}/${subnet.availability_zone}/${subnet.cidr_block}"].id
      cidr_block        = aws_subnet.this["${subnet.name}-${subnet.tier}/${subnet.availability_zone}/${subnet.cidr_block}"].cidr_block
      availability_zone = aws_subnet.this["${subnet.name}-${subnet.tier}/${subnet.availability_zone}/${subnet.cidr_block}"].availability_zone
      route_table_name  = subnet.route_table_name
      route_table_id    = aws_route_table.this["${subnet.route_table_name}"].id
    }
  }
}
