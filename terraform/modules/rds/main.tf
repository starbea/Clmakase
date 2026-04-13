######################################################
# RDS MySQL Module
#
# 구성:
# 1. DB Subnet Group - RDS 인스턴스용 서브넷 그룹
# 2. RDS Instance    - MySQL 데이터베이스 인스턴스
######################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

######################################################
# DB Subnet Group
# - RDS 인스턴스가 배치될 서브넷 그룹
# - Private Data Subnet을 사용하여 DB를 외부에서 격리
######################################################
resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-dbsg"
  subnet_ids = var.private_data_subnet_ids

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-dbsg"
    }
  )
}

######################################################
# RDS MySQL Instance
# - 개발 환경용 MySQL RDS 인스턴스
######################################################
resource "aws_db_instance" "this" {
  identifier             = "${local.name_prefix}-mysql"

  engine                 = "mysql"
  engine_version         = var.engine_version
  instance_class         = var.instance_class

  allocated_storage      = var.allocated_storage
  storage_type           = "gp3"
  storage_encrypted      = true

  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  port                   = 3306

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]

  publicly_accessible    = false
  multi_az               = var.multi_az
  availability_zone      = var.multi_az ? null : var.availability_zone

  skip_final_snapshot    = true
  apply_immediately      = true

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-mysql"
    }
  )
}