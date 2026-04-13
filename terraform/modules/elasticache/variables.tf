variable "project_name" {
  description = "Project name for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "private_data_subnet_ids" {
  description = "Private data subnet IDs for the Redis subnet group"
  type        = list(string)
}

variable "redis_sg_id" {
  description = "Security group ID for Redis"
  type        = string
}

variable "engine_version" {
  description = "Redis engine version"
  type        = string
}

variable "node_type" {
  description = "Node type for the Redis cluster"
  type        = string
}

variable "redis_port" {
  description = "Port number for Redis"
  type        = number
  default     = 6379
}

variable "parameter_group_name" {
  description = "Parameter group name for Redis"
  type        = string
}

variable "num_cache_clusters" {
  description = "Number of cache clusters"
  type        = number
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover"
  type        = bool
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ deployment"
  type        = bool
}

variable "at_rest_encryption_enabled" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Enable encryption in transit"
  type        = bool
  default     = true
}

variable "snapshot_retention_limit" {
  description = "Snapshot retention period in days"
  type        = number
  default     = 0
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}