#-----------------------------
#  ECS CLUSTER
#-----------------------------

resource "aws_ecs_cluster" "party_cluster" {
  name = "party-cluster"
}



#----------------------------
#  ECS TASK EXECUTION ROLE
#----------------------------

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



#--------------------------------------
#  TASK DEFINITION (Private Fargate)
#--------------------------------------

resource "aws_ecs_task_definition" "party_task" {
  family                   = "party-app-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "party-app"
      image     = "${aws_ecr_repository.auth_service.repository_url}:latest"
      essential = true

      portMappings = [{
        containerPort = 3000
        protocol      = "tcp"
      }]
    }
  ])
}



#------------------------------
#  ECS SERVICE (PRIVATE ONLY)
#------------------------------

resource "aws_ecs_service" "party_service" {
  name            = "party-app-service"
  cluster         = aws_ecs_cluster.party_cluster.id
  task_definition = aws_ecs_task_definition.party_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  # NO PUBLIC IP
  network_configuration {
    subnets          = var.private_subnets         # ← Use your private subnets
    security_groups  = [var.ecs_security_group_id] # ← Use your existing SG
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [task_definition] # allows pushing new images without TF errors
  }
}



#-------------------
#ECS load Balancer
#-------------------

load_balancer {
  target_group_arn = aws_lb_target_group.party_app_tg.arn
  container_name   = "party-app"
  container_port   = 3000
 }