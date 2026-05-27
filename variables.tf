variable "account_id" {
  type        = string
  description = "AWS account ID to designate as the Firewall Manager administrator. Defaults to the current account if not specified."
  default     = null
}
