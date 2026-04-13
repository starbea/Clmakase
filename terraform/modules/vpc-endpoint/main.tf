######################################################
# VPC Endpoints Module
#
# 구성:
# 1. ECR API Endpoint      - ECR 이미지 메타데이터 조회
# 2. ECR DKR Endpoint      - 이미지 레이어 다운로드
# 3. SSM Endpoint          - Session Manager 연결
# 4. SSM Messages Endpoint - Session Manager 내부 통신
# 5. EC2 Messages Endpoint - SSM Agent 메시지 전달
# 6. Logs Endpoint         - CloudWatch Logs 전송
# 7. STS Endpoint          - IRSA Role Assume
# 8. S3 Gateway Endpoint   - ECR 이미지 레이어용 S3 접근
######################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

######################################################
# ECR API Endpoint
# - ECR 이미지 메타데이터 조회에 사용
# - EKS Node -> ECR API
######################################################
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"

  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.endpoint_sg_id]
  private_dns_enabled = true
  
  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-vpce-ecr-api"
    }
  )
}

######################################################
# ECR DKR Endpoint
# - 실제 Docker 이미지 레이어 다운로드에 사용
# - EKS Node -> ECR API -> ECR DKR
######################################################
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"

  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.endpoint_sg_id]
  private_dns_enabled = true

  tags = merge(
    var.common_tags,
    {
        Name = "${local.name_prefix}-vpce-ecr-dkr"
    }
  )
}

######################################################
# SSM Endpoint
# - SSM Session Manager 연결에 사용
# - User -> SSM -> EC2
######################################################
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.endpoint_sg_id]
  private_dns_enabled = true

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-vpce-ssm"
    }
  )
}

######################################################
# SSM Messages Endpoint
# - Session Manager의 내부 WebSocket 통신에 사용
# - SSM -> SSM Messages -> EC2
######################################################
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.endpoint_sg_id]
  private_dns_enabled = true

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-vpce-ssmmessages"
    }
  )
}

######################################################
# EC2 Messages Endpoint
# - SSM Agent와 AWS 간 메시지 전달에 사용
# - EC2 -> SSM control plane
######################################################
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.endpoint_sg_id]
  private_dns_enabled = true

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-vpce-ec2messages"
    }
  )
}

######################################################
# CloudWatch Logs Endpoint
# - Pod 및 Node 로그를 CloudWatch Logs로 전송할 때 사용
# - Pod / Node -> CloudWatch Logs
######################################################
resource "aws_vpc_endpoint" "logs" {
  count               = var.enable_logs_endpoint ? 1 : 0
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.endpoint_sg_id]
  private_dns_enabled = true

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-vpce-logs"
    }
  )
}

######################################################
# STS Endpoint
# - IRSA 사용 시 Pod가 IAM Role을 Assume할 때 사용
# - Pod -> STS -> IAM Role
######################################################
resource "aws_vpc_endpoint" "sts" {
  count               = var.enable_sts_endpoint ? 1 : 0
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.sts"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [var.endpoint_sg_id]
  private_dns_enabled = true

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-vpce-sts"
    }
  )
}

######################################################
# S3 Gateway Endpoint
# - ECR 이미지 레이어가 저장된 S3 접근에 사용
# - EKS Node -> ECR API -> ECR DKR -> S3
######################################################
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-vpce-s3"
    }
  )
}