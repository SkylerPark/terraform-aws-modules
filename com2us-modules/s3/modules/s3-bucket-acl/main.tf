data "aws_canonical_user_id" "this" {}

resource "aws_s3_bucket_acl" "this" {
  bucket                = var.bucket
  expected_bucket_owner = var.expected_bucket_owner
  acl                   = var.acl == "null" ? null : var.acl

  dynamic "access_control_policy" {
    for_each = length(var.grants) > 0 ? [true] : []

    content {
      dynamic "grant" {
        for_each = var.grants

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
        id           = try(var.owner["id"], data.aws_canonical_user_id.this.id)
        display_name = try(var.owner["display_name"], null)
      }
    }
  }
}
