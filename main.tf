# ============================================================
#  ROOT main.tf  –  Entry point for all infrastructure
# ============================================================
#
#  HOW STATE WORKS (beginner-friendly):
#
#  Terraform needs to remember what it already created in AWS
#  so that next time it can compare "what exists" vs "what you want"
#  and only make the difference. This memory is called the STATE FILE.
#
#  We store the state file in an AWS S3 bucket (not in git).
#  S3 is persistent, shared, and accessible from every pipeline run.
#
#  Every pipeline run:
#    1. terraform init  → connects to S3, downloads latest state
#    2. terraform plan  → compares S3 state (current) vs tfvars (desired)
#                         If nothing changed → "No changes"
#                         If something changed → shows exactly what will change
#    3. terraform apply → applies only the difference, uploads new state to S3
#
#  DynamoDB table is used for STATE LOCKING:
#    Prevents two pipeline runs from running at the same time
#    and corrupting the state file.
#
#  ✅ No more: instance_id in tfvars, terraform import, git commits of state
# ============================================================

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ── S3 Backend – remote state storage ──────────────────────
  # State file lives here: s3://<bucket>/terraform/ec2/terraform.tfstate
  #
  # ⚠️  ONE-TIME SETUP REQUIRED (do this once manually before first run):
  #   1. Create S3 bucket:
  #      aws s3api create-bucket \
  #        --bucket terraform-state-<your-unique-name> \
  #        --region us-east-1
  #
  #   2. Enable versioning (lets you roll back state if something goes wrong):
  #      aws s3api put-bucket-versioning \
  #        --bucket terraform-state-<your-unique-name> \
  #        --versioning-configuration Status=Enabled
  #
  #   3. Create DynamoDB table for state locking:
  #      aws dynamodb create-table \
  #        --table-name terraform-state-lock \
  #        --attribute-definitions AttributeName=LockID,AttributeType=S \
  #        --key-schema AttributeName=LockID,KeyType=HASH \
  #        --billing-mode PAY_PER_REQUEST \
  #        --region us-east-1
  #
  #   4. Update the bucket name below to match what you created.
  #   5. Add bucket name as GitHub Secret: TF_STATE_BUCKET
  # ────────────────────────────────────────────────────────────
  backend "s3" {
    bucket         = "terraform-state-bucket-prasamjain"  # ← must match S3 bucket you created
    key            = "terraform/ec2/terraform.tfstate"    # path inside bucket where state is saved
    region         = "us-east-1"                          # must match bucket region
    dynamodb_table = "terraform-state-lock"               # must match DynamoDB table you created
    encrypt        = true                                 # encrypts state file at rest in S3
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
