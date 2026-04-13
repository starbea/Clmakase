######################################################
# ECR Module
#
# 구성:
# 1. ECR Repository      - Docker 이미지 저장소
# 2. Lifecycle Policy    - 오래된 이미지 정리 정책
######################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

######################################################
# ECR Repository
# - GitLab CI가 Docker 이미지를 push할 ECR 저장소
# - EKS 노드가 ECR에서 이미지를 pull할 때 사용
######################################################
resource "aws_ecr_repository" "this" {
  name                 =  var.repository_name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-${var.repository_name}"
    }
  )
}

######################################################
# ECR Lifecycle Policy
# - 오래된 이미지 정리를 위한 lifecycle policy
######################################################
resource "aws_ecr_lifecycle_policy" "this" {
  count      = var.enable_lifecycle_policy ? 1 : 0
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the most recent images"
        selection = {
          tagStatus   = var.lifecycle_tag_status
          countType   = "imageCountMoreThan"
          countNumber = var.lifecycle_max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}