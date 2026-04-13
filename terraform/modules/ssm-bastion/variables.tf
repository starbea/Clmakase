variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment(dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the SSM bastion EC2 will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the SSM bastion EC2 will be deployed"
  type        = string
}

variable "ami_id" {
  description = "AMI ID used for the SSM bastion EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the SSM bastion"
  type        = string
  default     = "t3.micro"
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the bastion EC2"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}