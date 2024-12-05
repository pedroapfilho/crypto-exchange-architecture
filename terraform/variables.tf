# AWS Region
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2"
}

# Cloudflare API Token
variable "cloudflare_api_token" {
  description = "API token for authenticating with Cloudflare."
  type        = string
  sensitive   = true
}

# Cloudflare Zone ID
variable "cloudflare_zone_id" {
  description = "The Zone ID for the Cloudflare domain."
  type        = string
}

# Database Username
variable "db_username" {
  description = "Username for the RDS database."
  type        = string
}

# Database Password
variable "db_password" {
  description = "Password for the RDS database."
  type        = string
  sensitive   = true
}

# Secrets Manager ARNs
variable "db_username_secret_arn" {
  description = "ARN of the Secrets Manager secret for the database username."
  type        = string
}

variable "db_password_secret_arn" {
  description = "ARN of the Secrets Manager secret for the database password."
  type        = string
}

# Secrets Manager Secret IDs
variable "db_username_secret_id" {
  description = "ID of the Secrets Manager secret for the database username."
  type        = string
}

variable "db_password_secret_id" {
  description = "ID of the Secrets Manager secret for the database password."
  type        = string
}

# VPC CIDR Block
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

# Public Subnet CIDR Blocks
variable "public_subnets" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# Private Subnet CIDR Blocks
variable "private_subnets" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

# Availability Zones
variable "availability_zones" {
  description = "List of availability zones to deploy resources in."
  type        = list(string)
  default     = ["us-west-2"]
}

# Lambda Function S3 Bucket
variable "lambda_s3_bucket" {
  description = "S3 bucket name where the Lambda deployment package is stored."
  type        = string
}

# Lambda Function S3 Key
variable "lambda_s3_key" {
  description = "S3 key path to the Lambda deployment package."
  type        = string
}

# Environment
variable "environment" {
  description = "The environment to deploy resources in (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}