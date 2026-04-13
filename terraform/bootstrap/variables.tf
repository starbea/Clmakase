variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cloudwave"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default = "cloudwave-terraform-state"
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default = "cloudwave-terraform-lock"
}