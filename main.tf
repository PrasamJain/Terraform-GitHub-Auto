# ============================================================
#  ROOT main.tf  –  Entry point for all infrastructure
# ============================================================
#
#  HOW IT WORKS (beginner-friendly):
#  1. AWS provider is declared here (region from tfvars)
#  2. We call the "ec2" module which holds the EC2 resource
#  3. All values come from terraform.tfvars.json
#
#  HOW UNIQUENESS WORKS:
#  - AWS Name tags are NOT unique → Terraform cannot use them
#    to find an existing EC2. Two EC2s can have the same name.
#  - Terraform uses instance_id (e.g. i-0abc1234) as the real identifier.
#  - The CI/CD pipeline stores instance_id in terraform.tfvars.json
#    after the first creation, and imports it on every re-run.
#  - This means: same ec2_name + same instance_id = update existing EC2
#                new ec2_name + empty instance_id  = create new EC2
# ============================================================

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ── AWS Provider ─────────────────────────────────────────────
provider "aws" {
  region = var.aws_region
}

# ── EC2 Module ───────────────────────────────────────────────
module "ec2" {
  source = "./modules/ec2"

  ec2_name      = var.ec2_name
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  tags          = var.tags
}

# ── Outputs ──────────────────────────────────────────────────
output "instance_id" {
  description = "The unique AWS ID of the EC2 instance (e.g. i-0abc1234)"
  value       = module.ec2.instance_id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.public_ip
}

output "instance_state" {
  description = "Current state: running / stopped / terminated"
  value       = module.ec2.instance_state
}
