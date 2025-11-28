# -----------------------------
# VPC
# -----------------------------
resource "aws_vpc" "party_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "party-with-me-vpc"
  }
}

# -----------------------------
# Private Subnet
# -----------------------------
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.party_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "party-with-me-private-subnet"
  }
}

# -----------------------------
# Security Group for Fargate Tasks
# -----------------------------
resource "aws_security_group" "ecs_sg" {
  name   = "party-with-me-ecs-sg"
  vpc_id = aws_vpc.party_vpc.id

  # Allow all outbound for pulling images and accessing CloudFront
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------
# VPC Endpoint for ECR
# -----------------------------
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.party_vpc.id
  service_name      = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet.id]
  security_group_ids = [aws_security_group.ecs_sg.id]
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.party_vpc.id
  service_name      = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet.id]
  security_group_ids = [aws_security_group.ecs_sg.id]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.party_vpc.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_vpc.party_vpc.main_route_table_id]
}
