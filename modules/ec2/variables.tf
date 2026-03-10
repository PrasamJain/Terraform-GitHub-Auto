# ============================================================
#  modules/ec2/variables.tf
# ============================================================

variable "ec2_name" {
  description = "Name tag and unique key for this EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID to launch (must exist in the selected region)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type e.g. t3.micro, t3.small"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access (empty string = no key)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Extra tags to apply on top of the Name tag"
  type        = map(string)
  default     = {}
}
