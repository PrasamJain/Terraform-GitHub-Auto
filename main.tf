# ============================================================
#  ROOT main.tf  –  Entry point for all infrastructure
# ============================================================
#
#  HOW IT WORKS (beginner-friendly explanation):
#  1. We declare the AWS provider here (region comes from tfvars)
#  2. We call the "ec2" module – the module does the actual work
#  3. All values are passed in via terraform.tfvars.json
#  4. State file is saved as:  tfstates/<ec2_name>.tfstate
#     → New name  = new state file (fresh EC2)
#     → Same name = Terraform updates the existing EC2 in place
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
# This calls ./modules/ec2 and passes all required variables
module "ec2" {
  source = "./modules/ec2"

  ec2_name      = var.ec2_name       # Name tag on the instance
  ami           = var.ami            # Amazon Machine Image ID
  instance_type = var.instance_type  # e.g. t3.micro
  key_name      = var.key_name       # SSH key pair name (optional)
  tags          = var.tags           # Extra tags (optional)
}

# ── Outputs ──────────────────────────────────────────────────
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.public_ip
}

output "instance_state" {
  description = "Current state of the EC2 instance"
  value       = module.ec2.instance_state
}
