output "admin_account_id" {
  description = "The AWS account ID of the FMS administrator."
  value       = try(aws_fms_admin_account.this[0].id, "")
}

output "enabled" {
  description = "Whether the module is enabled."
  value       = local.enabled
}
