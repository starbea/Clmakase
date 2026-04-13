variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment(dev, prod)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name used for subnet tagging and resource discovery"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks(EKS)"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_data_subnets" {
  description = "Private Data subnet CIDR blocks(ElastiCache/RDS)"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "nat_gateway_azs" {
  description = "Availability zones where NAT Gateways will be created"
  type        = set(string)
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}