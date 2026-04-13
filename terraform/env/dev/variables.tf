variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment(dev, prod)"
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
  description = "Availability zones for NAT Gateways"
  type        = set(string)
}

######################################################
# EKS Node Group
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
# RDS
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
  description = "MySQL engine version"
  type        = string
}

variable "instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
}

variable "allocated_storage" {
  description = "Storage size in GB"
  type        = number
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ deployment"
  type        = bool
}

variable "availability_zone" {
  description = "Availability zone for single-AZ RDS"
  type        = string
  default     = null
}

######################################################
# SSM Bastion
######################################################

variable "bastion_instance_type" {
  description = "EC2 instance type for the SSM bastion"
  type        = string
}