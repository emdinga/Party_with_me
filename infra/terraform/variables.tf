variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for deployment"
}

variable "project_name" {
  description = "project name"
  default     = "party-with-me"
}

variable "frontend_bucket_name" {
  type        = string
  description = "S3 bucket name for hosting the frontend website"
}


#-------------------
# ecs varaibles
#-------------------
variable "private_subnets" {
  description = "Private subnets for ECS tasks"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

# Private subnets for ECS tasks
variable "private_subnets" {
  description = "Private subnets for ECS tasks"
  type        = list(string)
}

# Security group for ECS tasks
variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

# Route tables for private subnets
variable "private_route_table_ids" {
  description = "Route tables associated with private subnets"
  type        = list(string)
}




