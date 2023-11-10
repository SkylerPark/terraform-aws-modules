module "ses-email-identity" {
  source   = "./modules/ses-email-identity"
  for_each = toset(var.emails)
  email    = each.key
}
