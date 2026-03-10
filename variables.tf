# ============================================================
#  variables.tf  –  Variable declarations for all resources
# ============================================================
#  Actual VALUES are set in terraform.tfvars.json
# ============================================================

variable "aws_region" {
  description = "AWS region where all resources will be created"
  type        = string
  default     = "us-east-1"
}

# ── EC2 ──────────────────────────────────────────────────────
variable "ec2_instances" {
  description = <<-EOT
    Map of EC2 instances. Each KEY is the unique name (used as Name tag).
    Add a new key   → new EC2 created
    Remove a key    → that EC2 destroyed
    Change a value  → that EC2 updated in place
    Re-run unchanged → No changes
  EOT
  type = map(object({
    ami           = string
    instance_type = string
    key_name      = string
    tags          = map(string)
  }))
  default = {}
}

# ── S3 ───────────────────────────────────────────────────────
variable "s3_buckets" {
  description = <<-EOT
    Map of S3 buckets. Each KEY is the bucket name (must be globally unique).
    Add a new key   → new bucket created
    Remove a key    → that bucket destroyed (only if force_destroy = true)
    Change a value  → that bucket updated in place
    Re-run unchanged → No changes
  EOT
  type = map(object({
    versioning_enabled = bool
    force_destroy      = bool
    tags               = map(string)
  }))
  default = {}
}

# ── IAM ──────────────────────────────────────────────────────
variable "iam_users" {
  description = <<-EOT
    Map of IAM users. Each KEY is the IAM username.
    Add a new key   → new IAM user created
    Remove a key    → that IAM user destroyed
    Change a value  → that IAM user updated in place
    Re-run unchanged → No changes
  EOT
  type = map(object({
    path        = string
    policy_arns = list(string)
    tags        = map(string)
  }))
  default = {}
}
