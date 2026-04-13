######################################################
# Aurora RDS Module
#
# 구성:
# 1. DB Subnet Group        - Aurora 클러스터용 서브넷 그룹
# 2. Aurora Cluster         - Aurora MySQL 클러스터
# 3. Aurora Writer Instance - 쓰기 전용 인스턴스
# 4. Aurora Reader Instance - 읽기 전용 인스턴스
######################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

######################################################
# DB Subnet Group
# - Aurora 클러스터가 배치될 서브넷 그룹
# - Private Data Subnet을 사용하여 Multi-AZ 구성
######################################################
resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-aurora-dbsg"
  subnet_ids = var.private_data_subnet_ids

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-aurora-dbsg"
    }
  )
}

######################################################
# Aurora Cluster
# - Aurora MySQL 클러스터 생성
######################################################
resource "aws_rds_cluster" "this" {
  cluster_identifier = "${local.name_prefix}-aurora-cluster"

  engine                  = "aurora-mysql"
  engine_version          = var.engine_version

  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password

  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.rds_sg_id]

  storage_encrypted       = true
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window

  skip_final_snapshot     = true

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-aurora-cluster"
    }
  )
}

######################################################
# Aurora Writer Instance
# - Aurora 클러스터의 기본 쓰기 인스턴스
######################################################
resource "aws_rds_cluster_instance" "writer" {
  identifier          = "${local.name_prefix}-aurora-writer"
  cluster_identifier  = aws_rds_cluster.this.id
  instance_class      = var.instance_class
  engine              = aws_rds_cluster.this.engine
  engine_version      = aws_rds_cluster.this.engine_version

  publicly_accessible = false

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-aurora-writer"
      Role = "writer"
    }
  )
}

######################################################
# Aurora Reader Instances
# - Aurora 클러스터의 읽기 전용 인스턴스
# - reader_count 값만큼 생성
######################################################
resource "aws_rds_cluster_instance" "reader" {
  count               = var.reader_count
  identifier          = "${local.name_prefix}-aurora-reader-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.this.id
  instance_class      = var.instance_class
  engine              = aws_rds_cluster.this.engine
  engine_version      = aws_rds_cluster.this.engine_version

  publicly_accessible = false

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-aurora-reader-${count.index + 1}"
      Role = "reader"
    }
  )
}