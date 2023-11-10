resource "aws_iam_user" "this" {
  for_each             = var.iam_users
  name                 = each.key
  path                 = var.path
  force_destroy        = var.force_destroy
  permissions_boundary = var.permissions_boundary

  tags = var.tags
}

resource "aws_iam_user_login_profile" "this" {
  for_each = { for key, value in var.iam_users : key => value if value.create_iam_user_login_profile }

  user                    = aws_iam_user.this[each.key].name
  pgp_key                 = var.pgp_key
  password_length         = var.password_length
  password_reset_required = var.password_reset_required

  lifecycle {
    ignore_changes = [password_reset_required, password_length]
  }
}

resource "aws_iam_access_key" "this" {
  # count = var.create_iam_access_key && var.pgp_key != "" ? 1 : 0
  for_each = { for key, value in var.iam_users : key => value if value.create_iam_access_key && var.pgp_key != "" }

  user    = aws_iam_user.this[each.key].name
  pgp_key = var.pgp_key
  status  = var.iam_access_key_status
}

resource "aws_iam_access_key" "this_no_pgp" {
  # count = var.create_iam_access_key && var.pgp_key == "" ? 1 : 0
  for_each = { for key, value in var.iam_users : key => value if value.create_iam_access_key && var.pgp_key == "" }

  user   = aws_iam_user.this[each.key].name
  status = var.iam_access_key_status
}

resource "aws_iam_user_ssh_key" "this" {
  for_each = { for key, value in var.iam_users : key => value if value.upload_iam_user_ssh_key }

  username   = aws_iam_user.this[each.key].name
  encoding   = var.ssh_key_encoding
  public_key = each.value.ssh_public_key
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each = {
    for user in flatten([
      for iam_name, value in var.iam_users : [
        for policy_arn in value.policy_arns : {
          user       = iam_name
          policy_arn = policy_arn
        }
      ]
  ]) : format("%s/%s", user.user, user.policy_arn) => user }

  user       = aws_iam_user.this[each.value.user].name
  policy_arn = each.value.policy_arn
}
