# ============================================================
#  ROOT main.tf  –  All AWS resources managed in one place
# ============================================================
#
#  RESOURCES MANAGED HERE:
#    - EC2 instances   (modules/ec2)
#    - S3 buckets      (modules/s3)
#    - IAM users       (modules/iam)
#
#  HOW TO ADD MORE RESOURCES:
#    1. Create a new folder under modules/ (e.g. modules/rds)
#    2. Add main.tf, variables.tf, outputs.tf inside it
#    3. Add a module block here calling it with for_each
#    4. Add the variable definition in variables.tf
#    5. Add the values in terraform.tfvars.json
#    → Same pipeline, same S3 state, zero other changes needed
#
#  ONE TFSTATE FILE IN S3 TRACKS EVERYTHING:
#    s3://terraform-state-bucket-prasamjain/terraform/all-resources/terraform.tfstate
#
#    Inside that file each resource is tracked individually:
#      module.ec2["web-server"].aws_instance.this
#      module.ec2["app-server"].aws_instance.this
#      module.s3["app-uploads"].aws_s3_bucket.this
#      module.s3["logs"].aws_s3_bucket.this
#      module.iam["dev-user"].aws_iam_user.this
#
#    Add/remove/change any one resource → only that resource is affected
#    Re-run unchanged                   → "No changes" for everything
# ============================================================

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ── S3 Backend ───────────────────────────────────────────
  # Single state file tracks ALL resources (EC2 + S3 + IAM + more)
  # ─────────────────────────────────────────────────────────
  backend "s3" {
    bucket         = "terraform-state-bucket-prasamjain"
    key            = "terraform/all-resources/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

# ── AWS Provider ─────────────────────────────────────────────
provider "aws" {
  region = var.aws_region
}

# ═════════════════════════════════════════════════════════════
#  EC2 INSTANCES
#  for_each creates one EC2 per entry in ec2_instances map
# ═════════════════════════════════════════════════════════════
module "ec2" {
  source   = "./modules/ec2"
  for_each = var.ec2_instances

  ec2_name      = each.key
  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = each.value.key_name
  tags          = each.value.tags
}

# ═════════════════════════════════════════════════════════════
#  S3 BUCKETS
#  for_each creates one S3 bucket per entry in s3_buckets map
# ═════════════════════════════════════════════════════════════
module "s3" {
  source   = "./modules/s3"
  for_each = var.s3_buckets

  bucket_name        = each.key
  versioning_enabled = each.value.versioning_enabled
  force_destroy      = each.value.force_destroy
  tags               = each.value.tags
}

# ═════════════════════════════════════════════════════════════
#  IAM USERS
#  for_each creates one IAM user per entry in iam_users map
# ═════════════════════════════════════════════════════════════
module "iam" {
  source   = "./modules/iam"
  for_each = var.iam_users

  user_name   = each.key
  path        = each.value.path
  policy_arns = each.value.policy_arns
  tags        = each.value.tags
}

# ═════════════════════════════════════════════════════════════
#  OUTPUTS  –  printed at end of every apply
# ═════════════════════════════════════════════════════════════

# ── EC2 outputs ──────────────────────────────────────────────
output "ec2_instance_ids" {
  description = "Map of EC2 name → AWS instance ID"
  value       = { for name, mod in module.ec2 : name => mod.instance_id }
}

output "ec2_public_ips" {
  description = "Map of EC2 name → public IP"
  value       = { for name, mod in module.ec2 : name => mod.public_ip }
}

output "ec2_states" {
  description = "Map of EC2 name → running/stopped"
  value       = { for name, mod in module.ec2 : name => mod.instance_state }
}

# ── S3 outputs ───────────────────────────────────────────────
output "s3_bucket_arns" {
  description = "Map of bucket name → ARN"
  value       = { for name, mod in module.s3 : name => mod.bucket_arn }
}

output "s3_bucket_domains" {
  description = "Map of bucket name → domain name"
  value       = { for name, mod in module.s3 : name => mod.bucket_domain_name }
}

# ── IAM outputs ──────────────────────────────────────────────
output "iam_user_arns" {
  description = "Map of IAM username → ARN"
  value       = { for name, mod in module.iam : name => mod.user_arn }
}
