module "zone" {
  source            = "./modules/zone"
  name              = var.name
  comment           = var.comment
  force_destroy     = var.force_destroy
  delegation_set_id = var.delegation_set_id
  vpc               = var.vpc
  tags              = merge(var.tags, var.zone_tags)
}

locals {
  records    = concat(var.records, try(jsondecode(var.records_jsonencoded), []))
  recordsets = { for rs in local.records : try(rs.key, join(" ", compact(["${rs.name} ${rs.type}", try(rs.set_identifier, "")]))) => rs }
}

module "records" {
  source   = "./modules/record"
  for_each = { for k, v in local.recordsets : k => v }

  zone_id                          = module.zone.id
  name                             = each.value.name != "" ? (lookup(each.value, "full_name_override", false) ? each.value.name : "${each.value.name}.${module.zone.name}") : module.zone.name
  type                             = each.value.type
  ttl                              = lookup(each.value, "ttl", null)
  records                          = try(each.value.records, null)
  set_identifier                   = lookup(each.value, "set_identifier", null)
  health_check_id                  = lookup(each.value, "health_check_id", null)
  multivalue_answer_routing_policy = lookup(each.value, "multivalue_answer_routing_policy", null)
  allow_overwrite                  = lookup(each.value, "allow_overwrite", false)

  alias                      = lookup(each.value, "alias", {})
  failover_routing_policy    = lookup(each.value, "failover_routing_policy", {})
  latency_routing_policy     = lookup(each.value, "latency_routing_policy", {})
  weighted_routing_policy    = lookup(each.value, "weighted_routing_policy", {})
  geolocation_routing_policy = lookup(each.value, "geolocation_routing_policy", {})
}
