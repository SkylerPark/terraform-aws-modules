data "aws_ec2_instance_type" "this" {
  for_each = toset(var.num_instances)

  instance_type = aws_instance.this[each.key].instance_type
}

output "instances" {
  description = "The Info of the instance All Resource"
  value = [
    for num in var.num_instances : {
      name              = "${var.name}-${num}"
      id                = aws_instance.this[num].id
      cpu               = data.aws_ec2_instance_type.this[num].default_vcpus
      memory            = data.aws_ec2_instance_type.this[num].memory_size / 1024
      private_ip        = aws_instance.this[num].private_ip
      public_ip         = var.create_eip ? aws_eip.this[num].public_ip : try(aws_instance.this[num].public_ip, "")
      availability_zone = aws_instance.this[num].availability_zone
      ebs_volum = [
        for disk in concat(var.root_block_device, var.ebs_block_device) : "EBS / ${disk.volume_size}"
      ]
    }
  ]
}
