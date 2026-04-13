######################################################
# EKS Module
#
# 구성:
# 1. EKS Cluster IAM Role   - EKS Control Plane용 IAM Role
# 2. IAM Policy Attachments - EKS 운영에 필요한 AWS 관리형 정책 연결
# 3. EKS Cluster            - Kubernetes Control Plane
# 4. OIDC Provider          - IRSA용 OIDC Provider
######################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

######################################################
# EKS Cluster IAM Role
# - AWS가 EKS Control Plane을 생성하고 관리하기 위한 IAM Role
######################################################
resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.name_prefix}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-eks-cluster-role"
    }
  )
}

# - EKS 클러스터 기본 관리 권한 연결
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# - ENI 및 보안 그룹 등 VPC 리소스 제어 권한 연결
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

######################################################
# EKS Cluster
# - Kubernetes Control Plane 생성
######################################################
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-eks-cluster"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]
}

######################################################
# OIDC Provider
# - Kubernetes ServiceAccount가 IAM Role을 Assume할 수 있도록 연결
# - IRSA 구성을 위해 사용
######################################################
data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-eks-oidc"
    }
  )
}
