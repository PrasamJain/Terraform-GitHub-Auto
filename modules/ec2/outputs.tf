# ============================================================
#  modules/ec2/outputs.tf
# ============================================================

output "instance_id" {
  description = "Unique AWS instance ID e.g. i-0abc1234567890"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address (empty if no public IP assigned)"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Private IP address inside the VPC"
  value       = aws_instance.this.private_ip
}

output "instance_state" {
  description = "Current state: running / stopped / terminated"
  value       = aws_instance.this.instance_state
}
