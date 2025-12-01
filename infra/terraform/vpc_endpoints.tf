# ECR API
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.party_with_me_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = [var.ecs_security_group_id]
  private_dns_enabled = true
}

# ECR DKR
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.party_with_me_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = [var.ecs_security_group_id]
  private_dns_enabled = true
}

# S3 (Gateway endpoint)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.party_with_me_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids
}