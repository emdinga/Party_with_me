# ----------------------------
# VPC
# ----------------------------
resource "aws_vpc" "party_with_me_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
c


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