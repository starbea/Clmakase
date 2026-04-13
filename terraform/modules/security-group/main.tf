######################################################
# Security Groups Module
#
# SG 구성:
# 1. ALB SG          - Internet → ALB
# 2. EKS Node SG     - Worker node communication
# 3. RDS SG          - MySQL access
# 4. Redis SG        - ElastiCache access
# 5. VPC Endpoint SG - Interface endpoint access
# 6. Bastion SG      - SSM bastion instance
######################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

######################################################
# ALB Security Group
# - 인터넷 → ALB(80, 443)
######################################################
resource "aws_security_group" "alb" {
  name_prefix = "${local.name_prefix}-alb-"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-alb-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from internet (redirect to HTTPS)"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = { Name = "alb-http-ingress" }
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from internet"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = { Name = "alb-https-ingress" }
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  description       = "All outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = { Name = "alb-all-egress" }
}

######################################################
# EKS Node Security Group
# - ALB -> EKS(8080)
# - Node <-> Node
######################################################
resource "aws_security_group" "eks_node" {
  name_prefix = "${local.name_prefix}-eks-node-"
  description = "Security group for EKS Worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-eks-node-sg"
      "karpenter.sh/discovery" = var.cluster_name
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "node_from_alb_app" {
  security_group_id            = aws_security_group.eks_node.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"

  description                  = "ALB to node (app port 8080)"
  tags = { Name = "node-from-alb-app" }
}

resource "aws_vpc_security_group_ingress_rule" "eks_node_to_node" {
  security_group_id            = aws_security_group.eks_node.id
  referenced_security_group_id = aws_security_group.eks_node.id
  ip_protocol                 = "-1"

  description                  = "Node to node communication"
  tags = { Name = "node-self-ingress" }
}

resource "aws_vpc_security_group_egress_rule" "eks_all_outbound" {
  security_group_id = aws_security_group.eks_node.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  description       = "All outbound traffic"
  tags = { Name = "node-all-egress" }
}

######################################################
# RDS Security Group
# - EKS Node → RDS(3306)
# - SSM Bastion → RDS(3306)
######################################################
resource "aws_security_group" "rds" {
  name_prefix = "${local.name_prefix}-rds-"
  description = "Security group for RDS MySQL"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-rds-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_eks" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.eks_node.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"

  description                  = "MySQL from EKS Node SG"
  tags                         = { Name = "rds-from-eks-node" }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_bastion" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.bastion.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"

  description                  = "MySQL from SSM bastion"
  tags                         = { Name = "rds-from-bastion" }
}

resource "aws_vpc_security_group_egress_rule" "rds_all_outbound" {
  security_group_id = aws_security_group.rds.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  description       = "All outbound traffic"
  tags = { Name = "rds-all-egress" }
}

######################################################
# Redis(ElastiCache) Security Group
# - EKS Node → Redis(6379)
# - SSM Bastion → Redis(6379)
######################################################
resource "aws_security_group" "redis" {
  name_prefix = "${local.name_prefix}-redis-"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-redis-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_eks" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = aws_security_group.eks_node.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"

  description                  = "Redis from EKS nodes"
  tags                         = { Name = "redis-from-eks-node" }
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_bastion" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = aws_security_group.bastion.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"

  description                  = "Redis from SSM bastion"
  tags                         = { Name = "redis-from-bastion" }
}

resource "aws_vpc_security_group_egress_rule" "redis_all_outbound" {
  security_group_id = aws_security_group.redis.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  description       = "All outbound traffic"
  tags              = { Name = "redis-all-egress" }
}

######################################################
# VPC endpoint Security Group
# - EKS Node → VPC endpoint(443)
# - SSM Bastion → VPC endpoint(443)
######################################################
resource "aws_security_group" "vpce" {
  name_prefix = "${local.name_prefix}-vpce-"
  description = "Security group for interface VPC endpoints"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-vpce-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "vpce_from_eks" {
  security_group_id            = aws_security_group.vpce.id
  referenced_security_group_id = aws_security_group.eks_node.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"

  description                  = "HTTPS from EKS nodes"
  tags                         = { Name = "vpce-from-eks-node" }
}

resource "aws_vpc_security_group_ingress_rule" "vpce_from_bastion" {
  security_group_id            = aws_security_group.vpce.id
  referenced_security_group_id = aws_security_group.bastion.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"

  description                  = "HTTPS from bastion"
  tags                         = { Name = "vpce-from-bastion" }
}

resource "aws_vpc_security_group_egress_rule" "vpce_all_outbound" {
  security_group_id = aws_security_group.vpce.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  description       = "All outbound traffic"
  tags              = { Name = "vpce-all-egress" }
}

######################################################
# SSM bastion(SSM)
######################################################
resource "aws_security_group" "bastion" {
  name_prefix = "${local.name_prefix}-bastion-"
  description = "Security group for SSM bastion instance"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-bastion-sg"
    }
  )
}

resource "aws_vpc_security_group_egress_rule" "bastion_all_outbound" {
  security_group_id = aws_security_group.bastion.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  description       = "All outbound traffic"
  tags              = { Name = "bastion-all-egress" }
}