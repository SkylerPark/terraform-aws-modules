module "cloudfront_distribution" {
  source = "./modules/distribution"
  count  = var.create_distribution ? 1 : 0

  create_origin_access_identity = var.create_origin_access_identity
  origin_access_identities      = var.origin_access_identities
  create_origin_access_control  = var.create_origin_access_control
  origin_access_control         = var.origin_access_control

  aliases             = var.aliases
  comment             = var.comment
  default_root_object = var.default_root_object
  enabled             = var.enabled
  http_version        = var.http_version
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
  web_acl_id          = var.web_acl_id
  tags                = var.tags

  logging_config         = var.logging_config
  origin                 = var.origin
  origin_group           = var.origin_group
  default_cache_behavior = var.default_cache_behavior
  ordered_cache_behavior = var.ordered_cache_behavior
  viewer_certificate     = var.viewer_certificate
  custom_error_response  = var.custom_error_response
  geo_restriction        = var.geo_restriction
}
