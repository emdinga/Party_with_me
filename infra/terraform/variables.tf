variable "aws_region" {
    type = string
    default = "us-east-1"
    description = "AWS region for deployment"
}

variable "project_name" {
    description = "project name"
    default = "party-with-me"
}

variable "frontend_bucket_name" {
  type        = string
  description = "S3 bucket name for hosting the frontend website"
}