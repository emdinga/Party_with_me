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