######################################################
# ElastiCache Redis Module
#
# 구성:
# 1. Subnet Group      - Redis용 서브넷 그룹
# 2. Replication Group - Redis 복제 그룹
######################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

######################################################
# ElastiCache Subnet Group
# - Redis가 배치될 서브넷 그룹
# - Private Data Subnet을 사용하여 외부 접근 차단
######################################################
resource "aws_elasticache_subnet_group" "this" {
  name       = "${local.name_prefix}-redis-sg"
  subnet_ids = var.private_data_subnet_ids

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-redis-sg"
    }
  )
}

######################################################
# ElastiCache Replication Group
# - 대기열 및 캐시 용도의 Redis 복제 그룹
######################################################
resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${local.name_prefix}-redis"
  description          = "${local.name_prefix} redis replication group"

  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = var.redis_port
  parameter_group_name = var.parameter_group_name

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [var.redis_sg_id]

  num_cache_clusters   = var.num_cache_clusters
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled

  snapshot_retention_limit = var.snapshot_retention_limit

  tags = merge(
    var.common_tags, 
    {
      Name = "${local.name_prefix}-redis"
    }
  )
}
