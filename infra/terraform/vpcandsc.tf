# ----------------------------
# VPC
# ----------------------------
resource "aws_vpc" "party_with_me_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "party-with-me-vpc"
  }
}

#-----------------
#VPC subnet
#-----------------
resource "aws_subnet" "party_with_me_private_subnet" {
  vpc_id                  = aws_vpc.party_with_me_vpc.id
  cidr_block              = "10.0.1.0/24" # use the subnet's CIDR
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "party-with-me-private-subnet"
  }
}

# ----------------------------
# Security Group
# ----------------------------
resource "aws_security_group" "party_with_me_sg" {
  name        = "party-with-me-sg"
  description = "Allow HTTP/HTTPS access"
  vpc_id      = aws_vpc.party_with_me_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "party-with-me-sg"
  }
}