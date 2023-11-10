output "instance_info" {
  description = "The Info of the instance All Resource"
  value = [
    for instance in module.instance : {
      name              = instance.name
      id                = instance.id
      cpu               = instance.cpu
      memory            = instance.memory
      disk              = instance.disk
      private_ip        = instance.private_ip
      public_ip         = instance.public_ip
      is_lb             = instance.is_lb
      os                = instance.os
      availability_zone = instance.availability_zone
    }
  ]
}

output "security_group_id" {
  description = "ID of the security group"
  value       = try(module.security_group[0].security_group_id, null)
}

output "temp_security_group_id" {
  description = "ID of the temp security group"
  value       = try([for tmp_sg in module.temp_security_group : tmp_sg.security_group_id], null)
}

output "instance_info_json" {
  description = "The Info of the instance All Resource"
  value = jsonencode([
    for instance in module.instance : {
      name              = instance.name
      id                = instance.id
      cpu               = instance.cpu
      memory            = instance.memory
      disk              = instance.disk
      private_ip        = instance.private_ip
      public_ip         = instance.public_ip
      os                = instance.os
      availability_zone = instance.availability_zone
    }
  ])
}
