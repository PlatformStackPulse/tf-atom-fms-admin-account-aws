# Unit Tests for tf-atom-fms-admin-account-aws
#
# These tests use a mock AWS provider — no real AWS calls are made.
# Run with:         terraform test -test-directory=tests/unit
# Run verbose:      terraform test -test-directory=tests/unit -verbose
# Run one test:     terraform test -test-directory=tests/unit -run "creates_when_enabled"

mock_provider "aws" {}

# Null-label (context.tf) required identity inputs plus this module's own inputs.
# account_id is optional (defaults to null → current account), so a valid sample
# 12-digit account id is supplied to exercise the pass-through path.
variables {
  namespace  = "eg"
  stage      = "test"
  name       = "thing"
  account_id = "123456789012"
}

# ---------------------------------------------------------------------------
# Test: module is enabled by default and computes a stable null-label id
# ---------------------------------------------------------------------------
run "creates_when_enabled" {
  command = plan

  # The null-label id is known at plan time and follows namespace-stage-name.
  assert {
    condition     = module.this.id == "eg-test-thing"
    error_message = "Expected null-label id 'eg-test-thing', got '${module.this.id}'."
  }

  # Exactly one FMS admin account resource is planned when enabled.
  assert {
    condition     = length(aws_fms_admin_account.this) == 1
    error_message = "Expected exactly one aws_fms_admin_account when enabled."
  }

  # The account_id input is passed through to the resource.
  assert {
    condition     = aws_fms_admin_account.this[0].account_id == "123456789012"
    error_message = "account_id should be passed through to the FMS admin account resource."
  }

  # The enabled output reflects the enabled state.
  assert {
    condition     = output.enabled == true
    error_message = "enabled output should be true when the module is enabled."
  }
}

# ---------------------------------------------------------------------------
# Test: disabling the module creates no resources
# ---------------------------------------------------------------------------
run "disabled_creates_nothing" {
  command = plan

  variables {
    enabled = false
  }

  assert {
    condition     = length(aws_fms_admin_account.this) == 0
    error_message = "No aws_fms_admin_account resource should be planned when disabled."
  }

  assert {
    condition     = output.enabled == false
    error_message = "enabled output should be false when the module is disabled."
  }

  # With count = 0, the try() in the admin_account_id output falls back to "".
  assert {
    condition     = output.admin_account_id == ""
    error_message = "admin_account_id output should be empty when the module is disabled."
  }
}
