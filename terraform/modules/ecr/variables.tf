variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment(dev, prod)"
  type        = string
}

variable "repository_name" {
  description = "Repository name for ECR"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting for ECR"
  type        = string
  default     = "MUTABLE"
}

variable "force_delete" {
  description = "Delete repository even if it contains images"
  type        = bool
  default     = false
}

variable "scan_on_push" {
  description = "Enable image scan on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for ECR"
  type        = string
  default     = "AES256"
}

variable "enable_lifecycle_policy" {
  description = "Enable lifecycle policy for ECR"
  type        = bool
  default     = true
}

variable "lifecycle_tag_status" {
  description = "Tag status for lifecycle policy (tagged, untagged, any)"
  type        = string
  default     = "any"
}

variable "lifecycle_max_image_count" {
  description = "Maximum number of images to keep"
  type        = number
  default     = 10
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}