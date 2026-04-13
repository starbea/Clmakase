######################################################
# Secrets Manager Module
#
# 구성:
# 1. Random Password        - DB 비밀번호 생성
# 2. Secrets Manager Secret - DB credential 저장
# 3. Secret Version         - 실제 Secret 값 저장
######################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

######################################################
# Secrets Manager Secret
# - 데이터베이스 인증 정보 저장을 위한 Secret 생성
######################################################
resource "aws_secretsmanager_secret" "db" {
  name        = "${local.name_prefix}/db"
  description = "Database credentials for ${local.name_prefix}"

  recovery_window_in_days = 0

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-db-secret"
    }
  )
}

# - 데이터베이스 비밀번호 자동 생성
resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

# - 실제 데이터베이스 credential 값 저장
resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  
  secret_string = jsonencode({
    db_name  = var.db_name
    username = var.db_username
    password = random_password.db_password.result
  })
}