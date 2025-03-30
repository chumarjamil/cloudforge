resource "aws_lb_target_group" "sonarqube" {
  count       = var.env == "Development" ? 1 : 0

  name        = "sonarqube"
  port        = 9000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    path = "/"
    matcher = "200,499"
    timeout = 60
    interval = 80
  }
}
