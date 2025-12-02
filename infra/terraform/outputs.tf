output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.party_with_me_users.id
}

output "cognito_user_pool_client_id" {
  description = "Client ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.party_with_me_client.id
}

# cloudfront out put 
#----------------------
output "cloudfront_domain" {
  description = "CloudFront distribution domain"
  value       = aws_cloudfront_distribution.frontend_cf.domain_name
}

#ecr output
#--------------------
output "auth_service_ecr_uri" {
  value = aws_ecr_repository.auth_service.repository_url
}

#vpc
output "vpc_id" {
  description = "The ID of the Party With Me VPC"
  value       = aws_vpc.party_with_me_vpc.id
}

output "subnet_id" {
  description = "The ID of the Party With Me Subnet"
  value       = aws_subnet.party_with_me_private_subnet.id
}

output "subnet_cidr" {
  description = "The CIDR block of the subnet"
  value       = aws_subnet.party_with_me_private_subnet.cidr_block
}

output "security_group_id" {
  description = "The ID of the Party With Me Security Group"
  value       = aws_security_group.party_with_me_sg.id
}

output "security_group_name" {
  description = "The name of the Party With Me Security Group"
  value       = aws_security_group.party_with_me_sg.name
}


#-----------------
# ECS outputs
#-----------------
output "ecs_cluster_name" {
  value = aws_ecs_cluster.party_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.party_service.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.party_task.arn
}

output "nlb_dns" {
  value = aws_lb.internal_nlb.dns_name
}

output "nlb_arn" {
  value = aws_lb.internal_nlb.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.party_app_tg.arn
}

output "api_gateway_invoke_url" {
  value = aws_api_gateway_deployment.party_api_deploy.invoke_url
}
