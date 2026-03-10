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
    NOTE: Name tags in AWS are NOT unique — Terraform does NOT use this
    to identify if an EC2 already exists. The real unique ID is instance_id.
    - Change this name → a NEW EC2 will be created (new instance_id)
    - Keep same name   → existing EC2 is updated in-place
  EOT
  type        = string
}

variable "instance_id" {
  description = <<-EOT
    AWS EC2 Instance ID (e.g. i-0abc1234567890).
    - Leave EMPTY ("") on first run → pipeline creates EC2 and fills this automatically.
    - After first run → pipeline writes the real instance_id here.
    - On every re-run → pipeline imports this ID into state so Terraform
      knows the EC2 already exists → plan shows 0 changes if nothing changed.
  EOT
  type    = string
  default = ""
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
