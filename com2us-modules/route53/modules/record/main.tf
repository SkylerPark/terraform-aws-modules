resource "aws_route53_record" "this" {
  zone_id                          = var.zone_id
  name                             = var.name
  type                             = var.type
  ttl                              = var.ttl
  records                          = var.records
  set_identifier                   = var.set_identifier
  health_check_id                  = var.health_check_id
  multivalue_answer_routing_policy = var.multivalue_answer_routing_policy
  allow_overwrite                  = var.allow_overwrite

  dynamic "alias" {
    for_each = length(var.alias) == 0 ? [] : [true]

    content {
      name                   = var.alias.name
      zone_id                = try(var.alias.zone_id, var.zone_id)
      evaluate_target_health = lookup(var.alias, "evaluate_target_health", false)
    }
  }

  dynamic "failover_routing_policy" {
    for_each = length(var.failover_routing_policy) == 0 ? [] : [true]

    content {
      type = var.failover_routing_policy.type
    }
  }

  dynamic "latency_routing_policy" {
    for_each = length(var.latency_routing_policy) == 0 ? [] : [true]

    content {
      region = var.latency_routing_policy.region
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = length(var.weighted_routing_policy) == 0 ? [] : [true]

    content {
      weight = var.weighted_routing_policy.weight
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = length(var.geolocation_routing_policy) == 0 ? [] : [true]

    content {
      continent   = lookup(var.geolocation_routing_policy, "continent", null)
      country     = lookup(var.geolocation_routing_policy, "country", null)
      subdivision = lookup(var.geolocation_routing_policy, "subdivision", null)
    }
  }
}
