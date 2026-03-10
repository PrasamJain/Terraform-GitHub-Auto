# ============================================================
#  modules/ec2/outputs.tf  –  Values this module exposes
# ============================================================

output "instance_id" {
  description = "The unique ID of the EC2 instance (e.g. i-0abc123)"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address (empty if instance has no public IP)"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "instance_state" {
  description = "Current state: running / stopped / terminated"
  value       = aws_instance.this.instance_state
}
