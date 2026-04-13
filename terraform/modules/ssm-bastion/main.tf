######################################################
# SSM Bastion Module
#
# 구성:
# 1. IAM Role              - EC2가 SSM에 연결하기 위한 권한
# 2. IAM Policy Attachment - AmazonSSMManagedInstanceCore 정책 연결
# 3. Instance Profile      - EC2에 IAM Role 연결
# 4. Bastion EC2 Instance  - Session Manager로 접근하는 관리용 인스턴스
######################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

######################################################
# IAM Role
# - EC2가 SSM에 연결하기 위한 IAM Role
# - AmazonSSMManagedInstanceCore 정책 연결
######################################################
resource "aws_iam_role" "this" {
  name = "${local.name_prefix}-ssm-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-ssm-bastion-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

######################################################
# IAM Instance Profile
# - EC2 인스턴스에 IAM Role을 연결하기 위한 Instance Profile
######################################################
resource "aws_iam_instance_profile" "this" {
  name = "${local.name_prefix}-ssm-bastion-profile"
  role = aws_iam_role.this.name
}

######################################################
# SSM Bastion EC2
# - SSM을 통해 관리자가 접근하는 Bastion 인스턴스
# - Public IP 없이 Private Subnet에서 실행
######################################################
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile = aws_iam_instance_profile.this.name

  associate_public_ip_address = false

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-ssm-bastion"
    }
  )
}