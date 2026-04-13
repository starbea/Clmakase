variable "project_name" {
  description = "Project name used for resource naming"
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

variable "private_subnet_ids" {
  description = "Private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "node_sg_id" {
  description = "Security group ID for EKS worker nodes"
  type        = string
}

variable "disk_size" {
  description = "Root volume size in GiB for worker nodes"
  type        = number
}

variable "node_subnet_ids" {
  description = "Private subnet IDs for the EKS node"
  type        = list(string)
}

variable "capacity_type" {
  description = "Capacity type for the node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
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

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}