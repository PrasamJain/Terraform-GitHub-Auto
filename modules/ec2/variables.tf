# ============================================================
#  modules/ec2/variables.tf  –  Inputs accepted by this module
# ============================================================

variable "ec2_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH (empty = no key)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}
