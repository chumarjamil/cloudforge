resource "random_integer" "ecs_service_dev" {
  count   = var.codedeploy == true ? 0 : 1
  min = 1024
  max = 3024
}

resource "random_integer" "ecs_service_prod" {
  count   = var.codedeploy == true ? 1 : 0
  min = 1024
  max = 3024
}

resource "aws_ecs_service" "ecs_service_dev" {
  count   = var.codedeploy == true ? 0 : 1

  name                    = var.name
  cluster                 = var.cluster_name
  launch_type             = "FARGATE"
  task_definition         = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count           = var.service_desired_count
  enable_execute_command  = true

  service_connect_configuration {
    enabled   = var.service_discovery_type == "http" ? "true" : "false"
    namespace = var.namespace_arn
    service {
      discovery_name = var.name
      port_name      = var.container_port_name
      ingress_port_override = random_integer.ecs_service_dev[0].result
      client_alias {
        dns_name = var.name
        port     = var.port
      }
    }
  }

  service_registries {
    registry_arn = var.service_discovery_type == "private_dns" ? aws_service_discovery_service.service_discovery_service[0].arn : null
  } 

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group[0].arn
    container_port   = var.port
    container_name   = var.name
  }

  network_configuration {
    subnets          = var.vpc_private_subnets
    assign_public_ip = false
    security_groups = [aws_security_group.ecs_security_group.id]
  }

  lifecycle {
    ignore_changes = [
      capacity_provider_strategy, load_balancer, task_definition
    ]
  }
}

resource "aws_ecs_service" "ecs_service_prod" {

  count   = var.codedeploy == true ? 1 : 0

  name                    = var.name
  cluster                 = var.cluster_name
  launch_type             = "FARGATE"
  task_definition         = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count           = var.service_desired_count
  scheduling_strategy     = "REPLICA"
  enable_execute_command  = true

  #service_connect_configuration {
  #  enabled   = var.service_discovery_type == "http" ? "true" : "false"
  #  namespace = var.namespace_arn
  #  service {
  #    discovery_name = var.name
  #    port_name      = var.container_port_name
  #    ingress_port_override = random_integer.ecs_service_prod[0].result
  #    client_alias {
  #      dns_name = var.name
  #      port     = var.port
  #    }
  #  }
  #}

  service_registries {
    registry_arn = var.service_discovery_type == "private_dns" ? aws_service_discovery_service.service_discovery_service[0].arn : null
  } 

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group_codedeploy[0].arn
    container_name   = var.name
    container_port   = var.port
  }

  network_configuration {
    subnets          = var.vpc_private_subnets
    assign_public_ip = false
    security_groups = [aws_security_group.ecs_security_group.id]
  }

  lifecycle {
    ignore_changes = [
      capacity_provider_strategy, load_balancer, task_definition
    ]
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}
