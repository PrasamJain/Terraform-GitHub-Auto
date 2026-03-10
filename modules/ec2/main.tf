# ============================================================
#  modules/ec2/main.tf  –  EC2 instance resource definition
# ============================================================
#  This module is called from the ROOT main.tf.
#  Do NOT add a provider block here – it inherits from root.
# ============================================================

resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type

  # Only attach key pair if key_name is provided
  key_name = var.key_name != "" ? var.key_name : null

  # Tags – always include the Name tag + any extra tags passed in
  tags = merge(
    { "Name" = var.ec2_name },
    var.tags
  )
}
