output "instance_id" {
  description = "ID of the SSM bastion EC2 instance"
  value       = aws_instance.this.id
}