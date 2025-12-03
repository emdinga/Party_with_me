# ----------------------------
# Network Load Balancer (Internal)
# ----------------------------
resource "aws_lb" "internal_nlb" {
  name                       = "${var.project_name}-internal-nlb"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = var.private_subnets
  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-internal-nlb"
  }
}

# ----------------------------
# Target Group (NLB) - target_type = ip for Fargate awsvpc
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
    path                = "/health" # change to your health endpoint or '/'
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
# Listener (NLB) - forward TCP 3000 to target group
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

# API resource (e.g. /api)
resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.party_api.id
  parent_id   = data.aws_api_gateway_resource.root.id
  path_part   = "api"
}

# Proxy resource to forward all paths
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.party_api.id
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "{proxy+}"
}

# ANY method on the proxy
resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id   = aws_api_gateway_rest_api.party_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

# Integration using VPC_LINK to NLB
resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.party_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy_any.http_method

  integration_http_method = "POST" # required but not used for HTTP_PROXY
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.nlb_vpc_link.id

  uri = "http://${aws_lb.internal_nlb.dns_name}/" # API Gateway will append the proxy path
}

# ----------------------------
# Deployment (no stage_name)
# ----------------------------
resource "aws_api_gateway_deployment" "party_api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.party_api.id

  triggers = {
    redeploy = timestamp() # ensures new deployment each apply
  }

  lifecycle {
    prevent_destroy       = true # Prevent Terraform from deleting active deployment
    create_before_destroy = true # Ensure new deployment is created before old one is removed
  }
}

# ----------------------------
# Stage
# ----------------------------
resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.party_api_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.party_api.id
}

# ----------------------------
# Output
# ----------------------------
output "api_gateway_invoke_url" {
  value = aws_api_gateway_stage.prod.invoke_url
}