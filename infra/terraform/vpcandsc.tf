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

# ----------------------------
# Private Subnet
# ----------------------------
resource "aws_subnet" "party_with_me_private_subnet" {
  vpc_id            = aws_vpc.party_with_me_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "party-with-me-private-subnet"
  }
}

# ----------------------------
# Route Table Association
# ----------------------------
resource "aws_route_table_association" "party_with_me_private_subnet_assoc" {
  subnet_id      = aws_subnet.party_with_me_private_subnet.id
  route_table_id = "rtb-07efde98cbefcebed" # main route table
}

# ----------------------------
# Security Group
# ----------------------------
# ----------------------------
# Security Group
# ----------------------------
resource "aws_security_group" "party_with_me_sg" {
  name        = "party-with-me-sg"
  description = "Allow HTTP/HTTPS access"
  vpc_id      = aws_vpc.party_with_me_vpc.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom TCP (NLB)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
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