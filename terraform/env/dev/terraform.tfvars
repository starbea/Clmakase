aws_region    = "ap-northeast-2"
project_name  = "oliveyoung"
environment   = "dev"

######################################################
# VPC
######################################################

vpc_cidr = "10.0.0.0/16"

public_subnets = {
  a = {
    cidr = "10.0.1.0/24"
    az   = "ap-northeast-2a"
  }
  c = {
    cidr = "10.0.2.0/24"
    az   = "ap-northeast-2c"
  }
}

private_subnets = {
  a = {
    cidr = "10.0.11.0/24"
    az   = "ap-northeast-2a"
  }
  c = {
    cidr = "10.0.12.0/24"
    az   = "ap-northeast-2c"
  }
}

private_data_subnets = {
  a = {
    cidr = "10.0.21.0/24"
    az   = "ap-northeast-2a"
  }
  c = {
    cidr = "10.0.22.0/24"
    az   = "ap-northeast-2c"
  }
}

nat_gateway_azs = ["a"]

######################################################
# EKS
######################################################

cluster_name    = "oliveyoung-dev-eks"
cluster_version = "1.32"

capacity_type  = "SPOT"
instance_types = ["t3.micro"]

desired_size    = 2
min_size        = 2
max_size        = 3
disk_size       = 20

######################################################
# ALB Controller
######################################################

alb_controller_chart_version = "1.7.2"

######################################################
# RDS
######################################################

engine_version    = "8.0"
instance_class    = "db.t3.micro"
allocated_storage = 20

db_name     = "oliveyoung_dev_mysql"
db_username = "admin"

multi_az             = false
availability_zone    = "ap-northeast-2a"

######################################################
# SSM Bastion
######################################################

bastion_instance_type = "t3.micro"