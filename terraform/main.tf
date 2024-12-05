# AWS Provider Configuration
provider "aws" {
  region = var.aws_region  # Set the AWS region from the variable
}

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Cloudflare Provider Configuration using API Token
provider "cloudflare" {
  api_token = var.cloudflare_api_token  # Set the Cloudflare API token from the variable
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"  # Source of the VPC module

  name = "exchange-vpc"  # Name of the VPC
  cidr = var.vpc_cidr  # CIDR block for the VPC

  azs             = var.availability_zones  # Availability zones from the variable
  private_subnets = var.private_subnets  # Private subnets from the variable
  public_subnets  = var.public_subnets  # Public subnets from the variable

  enable_nat_gateway = true  # Enable NAT gateway
  single_nat_gateway = true  # Use a single NAT gateway

  tags = {
    Terraform   = "true"  # Tag indicating Terraform management
    Environment = var.environment  # Environment tag from the variable
  }
}

# Cloudflare Configuration
resource "cloudflare_zone_settings_override" "settings" {
  zone_id = var.cloudflare_zone_id  # Cloudflare zone ID from the variable

  settings {
      brotli = "on"
      challenge_ttl = 2700
      security_level = "high"
      opportunistic_encryption = "on"
      automatic_https_rewrites = "on"
      mirage = "on"
      waf = "on"
      minify {
          css = "on"
          js = "off"
          html = "off"
      }
      security_header {
          enabled = true
      }
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "exchange-api"  # Name of the API Gateway
  description = "API Gateway for the exchange platform"  # Description of the API Gateway
}

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"  # Name of the IAM role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"  # Policy version
    Statement = [
      {
        Action    = "sts:AssumeRole"  # Action to assume the role
        Effect    = "Allow"  # Allow the action
        Principal = {
          Service = "lambda.amazonaws.com"  # Principal service is Lambda
        }
      }
    ]
  })
}

# Lambda Function: Wallet Service
resource "aws_lambda_function" "wallet_service" {
  function_name    = "wallet_service"  # Name of the Lambda function
  handler          = "index.handler"  # Handler for the Lambda function
  runtime          = "nodejs20.x"  # Updated runtime environment for the Lambda function
  role             = aws_iam_role.lambda_exec.arn  # IAM role ARN for the Lambda function
  s3_bucket        = var.lambda_s3_bucket  # S3 bucket for the Lambda deployment package
  s3_key           = var.lambda_s3_key  # S3 key for the Lambda deployment package
  publish          = true  # Publish the Lambda function

  environment {
    variables = {
      NODE_ENV = var.environment  # Environment variable for the Lambda function
    }
  }
}

resource "aws_lambda_alias" "wallet_service_alias" {
  name             = "prod"
  function_name    = aws_lambda_function.wallet_service.function_name
  function_version = "$LATEST"
}

# DynamoDB Table: Transaction Data
resource "aws_dynamodb_table" "transaction_data" {
  name         = "transaction_data"  # Name of the DynamoDB table
  billing_mode = "PAY_PER_REQUEST"  # Updated to use on-demand billing
  hash_key     = "transaction_id"  # Hash key for the DynamoDB table

  attribute {
    name = "transaction_id"  # Name of the attribute
    type = "S"  # Type of the attribute (String)
  }
}

# RDS Instance: User Data
resource "aws_db_instance" "user_data" {
  allocated_storage    = 20  # Allocated storage for the RDS instance
  storage_type         = "gp3"  # Updated storage type for the RDS instance
  engine               = "mysql"  # Database engine for the RDS instance
  engine_version       = "8.0"  # Engine version for the RDS instance
  instance_class       = "db.t3.micro"  # Instance class for the RDS instance
  username             = jsondecode(data.aws_secretsmanager_secret_version.db_username.secret_string)["username"]  # Username for the RDS database from Secrets Manager
  password             = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]  # Password for the RDS database from Secrets Manager
  parameter_group_name = "default.mysql8.0"  # Parameter group for the RDS instance
  skip_final_snapshot  = true  # Skip final snapshot on deletion

  vpc_security_group_ids = [module.vpc.default_security_group_id]  # Security group IDs for the RDS instance
  db_subnet_group_name   = aws_db_subnet_group.main.name  # Subnet group name for the RDS instance
}

# OpenSearch Domain: Search Interface
resource "aws_opensearch_domain" "search_interface" {
  domain_name    = "search-interface-${var.environment}"  # Name of the OpenSearch domain
  engine_version = "OpenSearch_2.9"  # Updated engine version

  cluster_config {
    instance_type        = "t3.small.search"  # Instance type for the OpenSearch domain
    instance_count       = 3  # Number of instances for the OpenSearch domain
    zone_awareness_enabled = true  # Enable zone awareness
    zone_awareness_config {
      availability_zone_count = 3  # Number of availability zones
    }
  }

  ebs_options {
    ebs_enabled = true  # Enable EBS storage
    volume_size = 10  # Volume size for EBS storage
  }

  node_to_node_encryption {
    enabled = true  # Enable node-to-node encryption
  }

  encrypt_at_rest {
    enabled = true  # Enable encryption at rest
  }

  domain_endpoint_options {
    enforce_https       = true  # Enforce HTTPS
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"  # TLS security policy
  }
}

# Fetch Secrets Manager Credentials
data "aws_secretsmanager_secret_version" "db_username" {
  secret_id = var.db_username_secret_id
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.db_password_secret_id
}

# Create DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "main-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "Main Subnet Group"
  }
}