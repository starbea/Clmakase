######################################################
# EKS Managed Node Group
#
# 구성:
# 1. Node Group IAM Role    - 워커 노드용 IAM Role
# 2. IAM Policy Attachments - 노드 운영에 필요한 정책 연결
# 3. Launch Template        - 디스크 및 보안 그룹 설정
# 4. EKS Managed Node Group - EKS 워커 노드 그룹
######################################################

######################################################
# Node Group IAM Role
# - EC2 워커 노드가 EKS 및 AWS 서비스와 통신하기 위한 IAM Role
######################################################
resource "aws_iam_role" "eks_node_group" {
  name = "${local.name_prefix}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-eks-node-role"
    }
  )
}

# - 워커 노드가 EKS 클러스터와 통신하기 위한 권한 연결
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

# - Pod 네트워크 및 ENI 관리를 위한 권한 연결
resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

# - ECR에서 컨테이너 이미지를 pull 하기 위한 권한 연결
resource "aws_iam_role_policy_attachment" "ecr_readonly_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

######################################################
# Launch Template
# - 워커 노드의 디스크 및 보안 그룹 설정
######################################################
resource "aws_launch_template" "node_template" {
  name_prefix = "${local.name_prefix}-node-lt-"

  vpc_security_group_ids = [
    var.node_sg_id,
    aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  ]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.disk_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
        Name = "${local.name_prefix}-node"
      }
    )
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-node-lt"
    }
  )
}

######################################################
# EKS Managed Node Group
# - EKS 클러스터에 연결되는 워커 노드 그룹
# - Launch Template과 Auto Scaling 설정을 사용
######################################################
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.name_prefix}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = var.node_subnet_ids

  capacity_type   = var.capacity_type
  instance_types  = var.instance_types

  launch_template {
    id      = aws_launch_template.node_template.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_readonly_policy,
  ]

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-node-group"
    }
  )
}