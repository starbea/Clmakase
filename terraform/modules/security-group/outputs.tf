output "alb_sg_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "eks_node_sg_id" {
  description = "EKS node security group ID"
  value       = aws_security_group.eks_node.id
}

output "rds_sg_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

output "redis_sg_id" {
  description = "Redis security group ID"
  value       = aws_security_group.redis.id
}

output "vpce_sg_id" {
  description = "VPC endpoint security group ID"
  value       = aws_security_group.vpce.id
}

output "bastion_sg_id" {
  description = "SSM bastion security group ID"
  value       = aws_security_group.bastion.id
}