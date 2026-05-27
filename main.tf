resource "aws_fms_admin_account" "this" {
  count = local.enabled ? 1 : 0

  account_id = var.account_id
}
