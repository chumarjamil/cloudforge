resource "aws_ecs_service" "sonarqube" {

  count = var.include_sonarqube ? 1 : 0

  name            = "sonarqube"
  cluster         = module.ecs_fargate_spot[0].cluster_id
  task_definition = aws_ecs_task_definition.sonarqube[0].arn
  desired_count   = 1
  #iam_role        = aws_iam_role.foo.arn
  #depends_on      = [aws_iam_role_policy.foo]

  load_balancer {
    target_group_arn = aws_lb_target_group.sonarqube[0].arn
    container_name   = "sonarqube"
    container_port   = 9000
  }

  network_configuration {
    subnets          = [module.vpc.private_subnets[0]]
    assign_public_ip = true
    security_groups = [aws_security_group.sonarqube[0].id]
  }

  lifecycle {
    ignore_changes = [capacity_provider_strategy]
  }

  depends_on = [
    aws_alb_listener.listener_http[0],
    aws_lb_listener.listener_https[0]
  ]
}
