aws_region   = "ap-northeast-2"
project_name = "cloudwave"
environment  = "prod"

######################################################
# VPC
######################################################

vpc_cidr     = "10.1.0.0/16"

public_subnets = {
  a = {
    cidr = "10.1.1.0/24"
    az   = "ap-northeast-2a"
  }
  c = {
    cidr = "10.1.2.0/24"
    az   = "ap-northeast-2c"
  }
}

private_subnets = {
  a = {
    cidr = "10.1.11.0/24"
    az   = "ap-northeast-2a"
  }
  c = {
    cidr = "10.1.12.0/24"
    az   = "ap-northeast-2c"
  }
}

private_data_subnets = {
  a = {
    cidr = "10.1.21.0/24"
    az   = "ap-northeast-2a"
  }
  c = {
    cidr = "10.1.22.0/24"
    az   = "ap-northeast-2c"
  }
}

nat_gateway_azs = ["a", "c"]

######################################################
# EKS
######################################################

cluster_name    = "oliveyoung-prod-eks"
cluster_version = "1.32"

capacity_type   = "ON_DEMAND"
instance_types = ["t3.micro"]

disk_size       = 20
desired_size    = 2
min_size        = 2
max_size        = 4

######################################################
# ALB Controller
######################################################

alb_controller_chart_version = "1.7.2"

######################################################
# Aurora
######################################################

engine_version          = "8.0.mysql_aurora.3.04.6"

db_name                 = "cloudwave_prod"
db_username             = "admin"

backup_retention_period = 1
preferred_backup_window = "03:00-04:00"

instance_class          = "db.t3.micro"
reader_count            = 0

######################################################
# Redis
######################################################

redis_engine_version       = "7.0"
redis_node_type            = "cache.t4g.micro"

redis_port                 = 6379
redis_parameter_group_name = "default.redis7"

num_cache_clusters         = 2
automatic_failover_enabled = true
multi_az_enabled           = true

at_rest_encryption_enabled = true
transit_encryption_enabled = true

snapshot_retention_limit = 1

######################################################
# SSM Bastion
######################################################

bastion_instance_type = "t3.micro"