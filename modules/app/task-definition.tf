resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = var.name
  execution_role_arn = var.task_execution_role_arn
  task_role_arn = var.task_role_arn
  network_mode = "awsvpc"

  runtime_platform {
    operating_system_family = "LINUX"
  }

  requires_compatibilities = ["FARGATE"]

  cpu = var.cpu
  memory = var.memory

  container_definitions = jsonencode([
  {
    name      = var.name
    image     = var.container_image
    cpu       = 0
    essential = true
    portMappings = [
      {
        containerPort = var.port
        hostPort      = var.port
        protocol      = "tcp"
        name          = var.container_port_name
      }
    ]
    HealthCheck: {
      Command: [
          "CMD-SHELL",
          "curl -f http://localhost:${var.port}${var.health_check_path} || exit 1"
      ]
      Interval: 5
      Timeout: 2
      Retries: 3
    }
    entryPoint = []
    logConfiguration = {
        logDriver = "awslogs"
        options = {
            awslogs-create-group = "true"
            awslogs-group = "/ecs/${var.name}"
            awslogs-region = "ap-southeast-1"
            awslogs-stream-prefix = "ecs"
        }
    }
  }])
}
