#-----------------------------
# ECS CLUSTER
#-----------------------------
resource "aws_ecs_cluster" "party_cluster" {
  name = "party-cluster"
}

#-----------------------------
# ECS TASK EXECUTION ROLE
#-----------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#-----------------------------
# ECS SECURITY GROUP
#-----------------------------
resource "aws_security_group" "ecs_sg" {
  name        = "party-app-ecs-sg"
  description = "Allow traffic from NLB"
  vpc_id      = aws_vpc.party_with_me_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For production, replace with NLB SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "party-app-ecs-sg" }
}

#--------------------------------------
# TASK DEFINITION (Private Fargate)
#--------------------------------------
resource "aws_ecs_task_definition" "party_task" {
  family                   = "party-app-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "party-app"
    image     = "${aws_ecr_repository.auth_service.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
  }])
}

#-----------------------------
# ECS SERVICE (PRIVATE + NLB)
#-----------------------------
resource "aws_ecs_service" "party_service" {
  name            = "party-app-service"
  cluster         = aws_ecs_cluster.party_cluster.id
  task_definition = aws_ecs_task_definition.party_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.party_app_tg.arn
    container_name   = "party-app"
    container_port   = 3000
  }

  lifecycle {
    ignore_changes = [task_definition] # allows pushing new images without TF errors
  }

  depends_on = [
    data.aws_lb_listener.party_app_listener
  ]
}

#-----------------------------
# DATA SOURCES (existing resources)
#-----------------------------
data "aws_lb_target_group" "party_app_tg" {
  name = "party-app-tg"
}

data "aws_lb_listener" "party_app_listener" {
  load_balancer_arn = data.aws_lb.internal_nlb.arn
  port              = 3000
}

data "aws_lb" "internal_nlb" {
  name = "party-internal-nlb"
}