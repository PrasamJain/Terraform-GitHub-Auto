# ============================================================
#  modules/ec2/main.tf
#  Single EC2 resource. Called once per entry via for_each.
# ============================================================

resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  tags = merge(
    {
      "Name"      = var.ec2_name
      "ManagedBy" = "Terraform"
    },
    var.tags
  )
}
