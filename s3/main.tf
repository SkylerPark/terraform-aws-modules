data "aws_canonical_user_id" "this" {
  count = local.create_bucket_acl && try(var.owner["id"], null) == null ? 1 : 0
}

locals {
  create_bucket_acl = (var.acl != null && var.acl != "null") || length(local.grants) > 0
  grants            = try(jsondecode(var.grant), var.grant)
  lifecycle_rules   = try(jsondecode(var.lifecycle_rule), var.lifecycle_rule)
  attach_policy     = var.attach_require_latest_tls_policy || var.attach_access_log_delivery_policy || var.attach_elb_log_delivery_policy || var.attach_lb_log_delivery_policy || var.attach_deny_insecure_transport_policy || var.attach_inventory_destination_policy || var.attach_deny_incorrect_encryption_headers || var.attach_deny_incorrect_kms_key_sse || var.attach_deny_unencrypted_object_uploads || var.attach_policy
}

resource "aws_s3_bucket" "this" {
  bucket              = var.bucket
  bucket_prefix       = var.bucket_prefix
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags                = var.tags
}

resource "aws_s3_bucket_logging" "this" {
  count  = length(keys(var.logging)) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  target_bucket = var.logging["target_bucket"]
  target_prefix = try(var.logging["target_prefix"], null)
}

resource "aws_s3_bucket_policy" "this" {
  count = local.attach_policy ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = jsonencode(var.policy)

  depends_on = [
    aws_s3_bucket_public_access_block.this
  ]
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.attach_public_policy ? 1 : 0

  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count = var.control_object_ownership ? 1 : 0

  bucket = local.attach_policy ? aws_s3_bucket_policy.this[0].id : aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }

  depends_on = [
    aws_s3_bucket_policy.this,
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket.this
  ]
}

resource "aws_s3_bucket_acl" "this" {
  count = local.create_bucket_acl ? 1 : 0

  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = var.expected_bucket_owner

  acl = var.acl == "null" ? null : var.acl

  dynamic "access_control_policy" {
    for_each = length(local.grants) > 0 ? [true] : []

    content {
      dynamic "grant" {
        for_each = local.grants

        content {
          permission = grant.value.permission

          grantee {
            type          = grant.value.type
            id            = try(grant.value.id, null)
            uri           = try(grant.value.uri, null)
            email_address = try(grant.value.email, null)
          }
        }
      }

      owner {
        id           = try(var.owner["id"], data.aws_canonical_user_id.this[0].id)
        display_name = try(var.owner["display_name"], null)
      }
    }
  }

  depends_on = [aws_s3_bucket_ownership_controls.this]
}

resource "aws_s3_bucket_versioning" "this" {
  count = length(keys(var.versioning)) > 0 ? 1 : 0

  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = var.expected_bucket_owner
  mfa                   = try(var.versioning["mfa"], null)

  versioning_configuration {
    status     = try(var.versioning["enabled"] ? "Enabled" : "Suspended", tobool(var.versioning["status"]) ? "Enabled" : "Suspended", title(lower(var.versioning["status"])))
    mfa_delete = try(tobool(var.versioning["mfa_delete"]) ? "Enabled" : "Disabled", title(lower(var.versioning["mfa_delete"])), null)
  }
}
