# ============================================================
#  variables.tf  –  All variable declarations for root module
# ============================================================
#  Actual VALUES are set in terraform.tfvars.json
# ============================================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "ec2_name" {
  description = <<-EOT
    Name tag for the EC2 instance.
    ⚠️  IMPORTANT:
      - Change this name → Terraform creates a NEW EC2 + a NEW state file (tfstates/<name>.tfstate)
      - Keep the same name → Terraform updates the EXISTING EC2
  EOT
  type        = string
}

variable "ami" {
  description = "AMI ID for the EC2 instance (must exist in the selected region)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (e.g. t2.micro, t3.micro, t3.small)"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 Key Pair for SSH access (leave empty string if not needed)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to the EC2 instance"
  type        = map(string)
  default     = {}
}
