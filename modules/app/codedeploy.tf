resource "aws_codedeploy_app" "default" {
  count   = var.codedeploy == true ? 1 : 0

  compute_platform = "ECS"
  name             = var.name
}

resource "aws_codedeploy_deployment_group" "default" {
  count   = var.codedeploy == true ? 1 : 0

  app_name               = var.name
  deployment_group_name  = "${var.name}-dg"
  service_role_arn       = var.ecs_codedeploy_role_arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  # You can configure options for a blue/green deployment.
  # https://docs.aws.amazon.com/codedeploy/latest/APIReference/API_BlueGreenDeploymentConfiguration.html
  blue_green_deployment_config {
    # Information about how traffic is rerouted to instances in a replacement environment in a blue/green deployment.
    deployment_ready_option {
      # Information about when to reroute traffic from an original environment to a replacement environment in a blue/green deployment.
      #
      # - CONTINUE_DEPLOYMENT: Register new instances with the load balancer immediately after the new application
      #                        revision is installed on the instances in the replacement environment.
      # - STOP_DEPLOYMENT: Do not register new instances with a load balancer unless traffic rerouting is started
      #                    using ContinueDeployment. If traffic rerouting is not started before the end of the specified
      #                    wait period, the deployment status is changed to Stopped.
      action_on_timeout = "CONTINUE_DEPLOYMENT"

      # The number of minutes to wait before the status of a blue/green deployment is changed to Stopped
      # if rerouting is not started manually. Applies only to the STOP_DEPLOYMENT option for action_on_timeout.
      # Can not be set to STOP_DEPLOYMENT when timeout is set to 0 minutes.
      # wait_time_in_minutes = "2"
    }

    # You can configure how instances in the original environment are terminated when a blue/green deployment is successful.
    terminate_blue_instances_on_deployment_success {
      # Valid values are TERMINATE or KEEP_ALIVE.
      # If specified TERMINATE, then instances are terminated after a specified wait time.
      # On the other hand, if specified KEEP_ALIVE, then occurred an unknown error when terraform apply.
      action = "TERMINATE"

      # The number of minutes to wait after a successful blue/green deployment before terminating instances
      # from the original environment. The maximum setting is 2880 minutes (2 days).
      termination_wait_time_in_minutes = "60"
    }
  }

  # For ECS deployment, the deployment type must be BLUE_GREEN, and deployment option must be WITH_TRAFFIC_CONTROL.
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  # Configuration block(s) of the ECS services for a deployment group.
  ecs_service {
    cluster_name = "${var.cluster_name}"
    service_name = "${aws_ecs_service.ecs_service_prod[0].name}"
  }

  auto_rollback_configuration {
    enabled = true
    events = [ "DEPLOYMENT_FAILURE" ]
  }

  # You can configure the Load Balancer to use in a deployment.
  load_balancer_info {
    # Information about two target groups and how traffic routes during an Amazon ECS deployment.
    # An optional test traffic route can be specified.
    # https://docs.aws.amazon.com/codedeploy/latest/APIReference/API_TargetGroupPairInfo.html
    target_group_pair_info {
      # The path used by a load balancer to route production traffic when an Amazon ECS deployment is complete.
      prod_traffic_route {
        listener_arns = ["${aws_lb_listener.listener_https[0].arn}"]
      }

      # One pair of target groups. One is associated with the original task set.
      # The second target is associated with the task set that serves traffic after the deployment completes.
      target_group {
        name = "${aws_lb_target_group.lb_target_group_codedeploy[0].name}"
      }

      target_group {
        name = "${aws_lb_target_group.lb_target_group_codedeploy[1].name}"
      }

    }
  }
}
