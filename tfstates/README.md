# This folder holds Terraform state files – one per EC2 name.
#
# Files are named:  <ec2_name>.tfstate
#
# Example:
#   tfstates/my-first-ec2.tfstate   ← created when ec2_name = "my-first-ec2"
#   tfstates/prod-server.tfstate    ← created when ec2_name = "prod-server"
#
# HOW THE LOGIC WORKS:
#   • Change ec2_name in terraform.tfvars.json → NEW state file → NEW EC2 created
#   • Keep same ec2_name                       → SAME state file → EXISTING EC2 updated
#
# NOTE: For real production use, consider storing state in S3 instead of Git.
