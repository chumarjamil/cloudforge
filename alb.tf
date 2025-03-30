resource "aws_lb" "alb" {
  count       = var.env == "Development" ? 1 : 0
  name            = "cloud-dev"
  security_groups = [aws_security_group.alb.id]
  subnets         = module.vpc.public_subnets
  tags = {
    Name = "cloud-dev-alb-sonarqube"
    Environment = var.env
  }
}

resource "aws_alb_listener" "listener_http" {
  count              = var.env == "Development" ? 1 : 0

  load_balancer_arn = "${aws_lb.alb[0].arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  depends_on = [
    aws_lb.alb[0],
  ]
}

resource "aws_lb_listener" "listener_https" {
  count              = var.env == "Development" ? 1 : 0

  load_balancer_arn = "${aws_lb.alb[0].arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.sonarqube[0].arn}"
  }

  depends_on = [
    aws_lb.alb[0],
  ]
}
