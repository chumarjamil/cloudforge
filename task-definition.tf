resource "aws_ecs_task_definition" "sonarqube" {
  count = var.include_sonarqube ? 1 : 0

  family = "sonarqube"
  execution_role_arn = aws_iam_role.task_execution_role.arn
  network_mode = "awsvpc"

  runtime_platform {
    operating_system_family = "LINUX"
  }

  requires_compatibilities = ["FARGATE"]

  cpu = "512"
  memory = "2048"

  container_definitions = file("container-definitions/sonarqube.json")

  volume {
    name = "data"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.sonarqube[0].id
      root_directory = "/"
      transit_encryption = "ENABLED"
      authorization_config {
          access_point_id = var.sonarqube_efs_accesspoint_id
          iam = "DISABLED"
      }
    }
  }
}
