variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev or prod)"
  type        = string
}

variable "region" {
  description = "AWS region where the VPC endpoints will be created"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the endpoints will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs where Interface Endpoints will be deployed"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "Route table IDs for private subnets (used for Gateway endpoints such as S3)"
  type        = list(string)
}

variable "endpoint_sg_id" {
  description = "Security Group ID attached to Interface VPC Endpoints"
  type        = string
}

variable "enable_logs_endpoint" {
  description = "Whether to create CloudWatch Logs VPC Endpoint (used for Fluent Bit / logging)"
  type        = bool
  default     = true
}

variable "enable_sts_endpoint" {
  description = "Whether to create STS VPC Endpoint (required for IRSA and IAM role assumption)"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags applied to all VPC endpoint resources"
  type        = map(string)
  default     = {}
}