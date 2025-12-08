resource "aws_cloudwatch_log_group" "ecs_auth_logs" {
  name              = "/ecs/auth-service"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "alb_logs" {
  name              = "/alb/app"
  retention_in_days = 30
}
