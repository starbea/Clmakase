######################################################
# ALB Controller Module
#
# 구성:
# 1. ServiceAccount      - ALB Controller Pod용 ServiceAccount
# 2. IRSA Role           - ServiceAccount가 사용할 IAM Role
# 3. IAM Policy          - ALB Controller 권한 정책
# 4. IAM Role Attachment - IAM Role에 정책 연결
# 5. Helm Release        - AWS Load Balancer Controller 설치
######################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

######################################################
# ServiceAccount
# - ALB Controller Pod가 사용할 ServiceAccount
# - IRSA Role annotation을 통해 IAM Role과 연결
######################################################
resource "kubernetes_service_account_v1" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
}

######################################################
# IRSA Role
# - ALB Controller ServiceAccount가 사용할 IAM Role
# - kube-system 네임스페이스의 aws-load-balancer-controller만 Assume 가능하도록 제한
######################################################
resource "aws_iam_role" "alb_controller" {
  name = "${local.name_prefix}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.cluster_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.cluster_oidc_provider_url}:aud" = "sts.amazonaws.com"
            "${var.cluster_oidc_provider_url}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-alb-controller-role"
    }
  )
}

######################################################
# IAM Policy
# - ALB, Target Group, Listener 등 AWS Load Balancer 리소스를
#   생성하고 관리하기 위한 권한 정책
######################################################
resource "aws_iam_policy" "alb_controller" {
  name   = "${local.name_prefix}-alb-controller-policy"
  policy = file("${path.module}/iam-policy.json")

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-alb-controller-policy"
    }
  )
}

# - ALB Controller Role에 AWS 권한 정책 연결
resource "aws_iam_role_policy_attachment" "alb_controller" {
  policy_arn = aws_iam_policy.alb_controller.arn
  role       = aws_iam_role.alb_controller.name
}

######################################################
# Helm Release
# - AWS Load Balancer Controller Helm 차트 설치
# - 미리 생성한 ServiceAccount를 사용하도록 설정
######################################################
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = var.chart_version

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  depends_on = [
    kubernetes_service_account_v1.alb_controller,
    aws_iam_role_policy_attachment.alb_controller
  ]
}