locals {
  lifecycle_rules = try(jsondecode(var.lifecycle_rule), var.lifecycle_rule)
  grants          = try(jsondecode(var.grant), var.grant)
}

module "s3_bucket" {
  source              = "./modules/s3-bucket"
  count               = var.create_bucket ? 1 : 0
  bucket              = var.bucket
  bucket_prefix       = var.bucket_prefix
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags                = var.tags
}

module "s3_bucket_policy" {
  source = "./modules/s3-bucket-policy"
  count  = var.create_bucket && var.attach_policy ? 1 : 0
  bucket = module.s3_bucket[0].id
  policy = var.policy
}

module "s3_bucket_acl" {
  source = "./modules/s3-bucket-acl"
  count  = var.create_bucket && ((var.acl != null && var.acl != "null") || length(local.grants) > 0) ? 1 : 0
  bucket = module.s3_bucket[0].id
  acl    = var.acl
  grants = local.grants
  owner  = var.owner
}

module "s3_bucket_versioning" {
  source                = "./modules/s3-bucket-versioning"
  count                 = var.create_bucket && length(keys(var.versioning)) > 0 ? 1 : 0
  bucket                = module.s3_bucket[0].id
  expected_bucket_owner = var.expected_bucket_owner
  versioning            = var.versioning
}

module "s3_bucket_lifecycle_configuration" {
  source                = "./modules/s3-bucket-lifecycle-configuration"
  count                 = var.create_bucket && length(local.lifecycle_rules) > 0 ? 1 : 0
  bucket                = module.s3_bucket[0].id
  expected_bucket_owner = var.expected_bucket_owner
  lifecycle_rules       = local.lifecycle_rules
  depends_on = [
    module.s3_bucket_versioning
  ]
}

module "s3_bucket_notification" {
  source               = "./modules/notification"
  count                = var.create_bucket && var.create_notification ? 1 : 0
  bucket               = module.s3_bucket[0].id
  eventbridge          = var.eventbridge
  lambda_notifications = var.lambda_notifications
  sqs_notifications    = var.sqs_notifications
  sns_notifications    = var.sns_notifications
}
