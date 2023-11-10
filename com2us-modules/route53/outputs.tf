output "route53_info" {
  description = "route53 info"
  value = {
    name = try(module.zone[0].name, "")
    record = [for r in module.records : {
      name    = r.name
      records = r.records
    }]
  }
}
