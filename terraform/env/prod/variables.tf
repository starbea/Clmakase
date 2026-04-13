variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

######################################################
# VPC
######################################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet settings"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "Private subnet settings"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_data_subnets" {
  description = "Private data subnet settings"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "nat_gateway_azs" {
  description = "Availability zones where NAT Gateways will be created"
  type        = set(string)
}

######################################################
# EKS
######################################################

variable "capacity_type" {
  description = "Capacity type for the EKS node group"
  type        = string
}

variable "instance_types" {
  description = "EKS managed node group instance types"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "disk_size" {
  description = "Root volume size in GiB for worker nodes"
  type        = number
}

######################################################
# ALB Controller
######################################################

variable "alb_controller_chart_version" {
  description = "Helm chart version for AWS Load Balancer Controller"
  type        = string
}

######################################################
# Aurora
######################################################

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
}

variable "engine_version" {
  description = "Aurora MySQL engine version"
  type        = string
}

variable "instance_class" {
  description = "Instance class for Aurora instances"
  type        = string
}

variable "reader_count" {
  description = "Number of Aurora reader instances"
  type        = number
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
}

variable "preferred_backup_window" {
  description = "Preferred backup window in UTC"
  type        = string
}

######################################################
# Redis
######################################################

variable "redis_engine_version" {
  description = "Redis engine version"
  type        = string
}

variable "redis_node_type" {
  description = "Node type for Redis"
  type        = string
}

variable "redis_port" {
  description = "Port number for Redis"
  type        = number
}

variable "redis_parameter_group_name" {
  description = "Parameter group name for Redis"
  type        = string
}

variable "num_cache_clusters" {
  description = "Number of Redis cache clusters"
  type        = number
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover for Redis"
  type        = bool
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ for Redis"
  type        = bool
}

variable "at_rest_encryption_enabled" {
  description = "Enable encryption at rest for Redis"
  type        = bool
}

variable "transit_encryption_enabled" {
  description = "Enable encryption in transit for Redis"
  type        = bool
}

variable "snapshot_retention_limit" {
  description = "Snapshot retention period in days for Redis"
  type        = number
}

######################################################
# SSM Bastion
######################################################

variable "bastion_instance_type" {
  description = "EC2 instance type for the SSM bastion"
  type        = string
}