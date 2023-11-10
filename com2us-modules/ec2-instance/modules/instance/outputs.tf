output "id" {
  description = "The ID of the instance"
  value       = aws_instance.this.id
}

output "name" {
  description = "The Name of the instance"
  value       = var.instance_name
}

output "cpu" {
  description = "The CPU of the instance"
  value       = data.aws_ec2_instance_type.this.default_vcpus
}

output "memory" {
  description = "The Memory of the instance (GiB)"
  value       = data.aws_ec2_instance_type.this.memory_size / 1024
}

output "disk" {
  description = "The Disk of the instance "
  value = length(var.ebs_block_device) > 0 ? [
    for disk in concat(var.root_block_device, var.ebs_block_device) : "vHDD / ${disk.volume_size}"
  ] : [for disk in concat(var.root_block_device, var.attachment_ebs_block_device) : "vHDD / ${disk.volume_size}"]
}

output "private_ip" {
  description = "The private IP address assigned to the instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable. NOTE: If you are using an aws_eip with your instance, you should refer to the EIP's address directly and not use `public_ip` as this field will change after the EIP is attached"
  value       = module.instance_eip[0].public_ip
}

output "is_lb" {
  description = "The Is LB the instance"
  value       = var.is_lb
}

output "os" {
  description = "instance os version"
  value       = var.os == "rocky8" || var.ami == "ami-03451dd8b787d00c2" || var.ami == "ami-05bdf89e14d3e2e11" ? "Rocky 8.8" : var.os == "centos7" || var.ami == "ami-016eb6423a1575481" ? "Centos 7.9" : null
}

output "availability_zone" {
  description = "The availability zone of the created instance"
  value       = aws_instance.this.availability_zone
}
