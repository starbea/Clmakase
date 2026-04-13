locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

module "vpc" {
  source               = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  cluster_name         = var.cluster_name

  vpc_cidr             = var.vpc_cidr
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  private_data_subnets = var.private_data_subnets
  nat_gateway_azs      = var.nat_gateway_azs

  common_tags          = local.common_tags
}

module "security_group" {
  source       = "../../modules/security-group"

  project_name = var.project_name
  environment  = var.environment

  vpc_id       = module.vpc.vpc_id
  cluster_name = var.cluster_name

  common_tags  = local.common_tags
}

module "eks" {
  source             = "../../modules/eks"

  project_name       = var.project_name
  environment        = var.environment
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version

  private_subnet_ids = module.vpc.private_subnet_ids
  node_subnet_ids = module.vpc.private_subnet_ids

  capacity_type      = var.capacity_type
  instance_types   = var.instance_types
  desired_size       = var.desired_size
  min_size           = var.min_size
  max_size           = var.max_size

  node_sg_id         = module.security_group.eks_node_sg_id
  disk_size          = var.disk_size

  common_tags        = local.common_tags
}

module "alb_controller" {
  source                    = "../../modules/alb-controller"

  project_name              = var.project_name
  environment               = var.environment

  cluster_name              = module.eks.cluster_name
  vpc_id                    = module.vpc.vpc_id
  aws_region                = var.aws_region
  
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn
  cluster_oidc_provider_url = module.eks.oidc_provider_url

  chart_version             = var.alb_controller_chart_version

  common_tags               = local.common_tags
}

module "rds" {
  source                  = "../../modules/rds-aurora"

  project_name            = var.project_name
  environment             = var.environment

  private_data_subnet_ids = module.vpc.private_data_subnet_ids
  rds_sg_id               = module.security_group.rds_sg_id

  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = module.secrets.db_password

  engine_version          = var.engine_version
  instance_class          = var.instance_class
  reader_count            = var.reader_count

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window  

  common_tags             = local.common_tags
}

module "redis" {
  source                    = "../../modules/elasticache"

  project_name               = var.project_name
  environment                = var.environment
  private_data_subnet_ids         = module.vpc.private_data_subnet_ids
  redis_sg_id                = module.security_group.redis_sg_id

  engine_version             = var.redis_engine_version
  node_type                  = var.redis_node_type

  redis_port                 = var.redis_port
  parameter_group_name       = var.redis_parameter_group_name
  
  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled

  snapshot_retention_limit   = var.snapshot_retention_limit

  common_tags                = local.common_tags
}

module "secrets" {
  source       = "../../modules/secrets"
  project_name = var.project_name
  environment  = var.environment

  db_username  = var.db_username
  db_name      = var.db_name
  
  common_tags  = local.common_tags
}

module "vpc_endpoint" {
  source = "../../modules/vpc-endpoint"

  project_name            = var.project_name
  environment             = var.environment
  region                  = var.aws_region

  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  private_route_table_ids = module.vpc.private_route_table_ids

  endpoint_sg_id          = module.security_group.vpce_sg_id

  enable_logs_endpoint    = true
  enable_sts_endpoint     = true

  common_tags             = local.common_tags
}

module "ssm_bastion" {
  source = "../../modules/ssm-bastion"

  project_name       = var.project_name
  environment        = var.environment

  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.private_subnet_ids[0]

  ami_id             = data.aws_ami.amazon_linux_2023.id
  instance_type      = var.bastion_instance_type

  security_group_ids = [module.security_group.bastion_sg_id]

  common_tags        = local.common_tags
}

module "ecr" {
  source                    = "../../modules/ecr"

  project_name              = var.project_name
  environment               = var.environment
  repository_name           = "oliveyoung-api"

  image_tag_mutability      = "IMMUTABLE"
  force_delete              = false
  scan_on_push              = true
  enable_lifecycle_policy   = true
  lifecycle_max_image_count = 10

  common_tags               = local.common_tags
}