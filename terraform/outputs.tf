# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

# API Gateway Output
output "api_gateway_id" {
  description = "The ID of the API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}

# Lambda Function Output
output "wallet_service_function_name" {
  description = "The name of the Wallet Service Lambda function"
  value       = aws_lambda_function.wallet_service.function_name
}

# Lambda Function Alias Output
output "wallet_service_alias_arn" {
  description = "The ARN of the Wallet Service Lambda function alias"
  value       = aws_lambda_alias.wallet_service_alias.arn
}

# DynamoDB Table Output
output "transaction_data_table_name" {
  description = "The name of the Transaction Data DynamoDB table"
  value       = aws_dynamodb_table.transaction_data.name
}

# RDS Instance Output
output "user_data_db_endpoint" {
  description = "The endpoint of the User Data RDS instance"
  value       = aws_db_instance.user_data.endpoint
}

# OpenSearch Domain Output
output "search_interface_endpoint" {
  description = "The endpoint of the Search Interface OpenSearch domain"
  value       = aws_opensearch_domain.search_interface.endpoint
}

# AWS Region Output
output "aws_region" {
  description = "The AWS region where resources are deployed"
  value       = var.aws_region
}