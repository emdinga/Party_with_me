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
}

resource "aws_route_table_association" "party_with_me_private_subnet_assoc" {
  subnet_id      = aws_subnet.party_with_me_private_subnet.id
  route_table_id = "rtb-07efde98cbefcebed" # main route table
}

# ----------------------------
# Security Group
# ----------------------------
resource "aws_security_group" "party_with_me_sg" {
  name        = "party-with-me-sg"
  description = "Allow HTTP/HTTPS and NLB traffic"
  vpc_id      = aws_vpc.party_with_me_vpc.id

  # Allow HTTP/HTTPS from anywhere
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

  # Allow NLB to reach ECS tasks on 3000
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.party_with_me_sg.id] # NLB SG
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

# ----------------------------
# Network Load Balancer (Internal)
# ----------------------------
resource "aws_lb" "internal_nlb" {
  name                       = "${var.project_name}-internal-nlb"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = [aws_subnet.party_with_me_private_subnet.id]
  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-internal-nlb"
  }
}

# ----------------------------
# NLB Target Group
# ----------------------------
resource "aws_lb_target_group" "party_app_tg" {
  name        = "${var.project_name}-tg"
  port        = 3000
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.party_with_me_vpc.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# ----------------------------
# Listener
# ----------------------------
resource "aws_lb_listener" "party_app_listener" {
  load_balancer_arn = aws_lb.internal_nlb.arn
  port              = 3000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.party_app_tg.arn
  }
}

# ----------------------------
# ECS Cluster
# ----------------------------
resource "aws_ecs_cluster" "party_cluster" {
  name = "party-cluster"
}

# ----------------------------
# ECS Task Definition
# ----------------------------
resource "aws_ecs_task_definition" "party_task" {
  family                   = "party-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "party-app"
      image     = "<your-ECR-image>" # replace with your image
      essential = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 2
        startPeriod = 10
      }
    }
  ])
}

# ----------------------------
# ECS Service
# ----------------------------
resource "aws_ecs_service" "party_service" {
  name            = "party-app-service"
  cluster         = aws_ecs_cluster.party_cluster.id
  task_definition = aws_ecs_task_definition.party_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.party_with_me_private_subnet.id]
    security_groups = [aws_security_group.party_with_me_sg.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.party_app_tg.arn
    container_name   = "party-app"
    container_port   = 3000
  }
  depends_on = [aws_lb_listener.party_app_listener]
}

# ----------------------------
# API Gateway VPC Link
# ----------------------------
resource "aws_api_gateway_vpc_link" "nlb_vpc_link" {
  name        = "${var.project_name}-vpc-link"
  target_arns = [aws_lb.internal_nlb.arn]

  tags = {
    Name = "${var.project_name}-vpc-link"
  }
}

# ----------------------------
# API Gateway REST API
# ----------------------------
resource "aws_api_gateway_rest_api" "party_api" {
  name        = "${var.project_name}-api"
  description = "API for Party With Me (private via VPC Link)"
}

# Root resource
data "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.party_api.id
  path        = "/"
}

# API resource /api
resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.party_api.id
  parent_id   = data.aws_api_gateway_resource.root.id
  path_part   = "api"
}

# Proxy resource
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.party_api.id
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "{proxy+}"
}

# ANY method
resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id   = aws_api_gateway_rest_api.party_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

# Integration with VPC Link
resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.party_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_any.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.nlb_vpc_link.id
  uri                     = "http://${aws_lb.internal_nlb.dns_name}/"
}

# Deployment
resource "aws_api_gateway_deployment" "party_api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.party_api.id

  triggers = {
    redeploy = timestamp()
  }

  lifecycle {
    prevent_destroy       = true
    create_before_destroy = true
  }
}

# Stage
resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.party_api_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.party_api.id
}

# Output
output "api_gateway_invoke_url" {
  value = aws_api_gateway_stage.prod.invoke_url
}