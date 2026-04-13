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

variable "aws_region" {
  description = "AWS region where the cluster is deployed"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID used by the EKS cluster"
  type        = string
}

variable "chart_version" {
  description = "Helm chart version for AWS Load Balancer Controller"
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}

variable "cluster_oidc_provider_url" {
  description = "OIDC provider URL for IRSA (without https)"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}