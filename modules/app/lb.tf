resource "aws_lb_target_group" "lb_target_group" {
  count   = var.codedeploy == true ? 0 : 1

  name        = var.name
  port        = var.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    path = var.health_check_path
    matcher = var.lb_target_group_health_check_status_code
    timeout = 60
    interval = 80
  }
}

resource "aws_lb_target_group" "lb_target_group_codedeploy" {
  count   = var.codedeploy == true ? 2 : 0

  name        = "${var.name}${count.index}"
  port        = var.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    path = var.health_check_path
    matcher = var.lb_target_group_health_check_status_code
    timeout = 60
    interval = 80
  }
}

resource "aws_lb" "alb" {
  count   = var.codedeploy == true ? 1 : 0

  name            = var.name
  security_groups = [aws_security_group.alb[0].id]
  subnets         = var.vpc_public_subnets
  tags = {
    Name = "${var.name}-${var.env}"
    Environment = var.env
  }
}

resource "aws_alb_listener" "listener" {
  count   = var.codedeploy == true ? 1 : 0

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
  count   = var.codedeploy == true ? 1 : 0

  load_balancer_arn = "${aws_lb.alb[0].arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lb_target_group_codedeploy[0].arn}"
  }

  depends_on = [
    aws_lb_target_group.lb_target_group_codedeploy
  ]

  lifecycle {
    ignore_changes = [
      default_action["target_group_arn"]
    ]
  }
}

resource "aws_lb_listener_rule" "lb_listener_rule_alb" {
  count   = var.codedeploy == true ? 1 : 0

  listener_arn       = aws_lb_listener.listener_https[0].arn
  #priority          = 99

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lb_target_group_codedeploy[0].arn}"
  }

  condition {
    host_header {
      values = ["${var.domain}"]
    }
  }

  lifecycle {
    ignore_changes = [
      action["target_group_arn"]
    ]
  }
}

resource "aws_lb_listener_rule" "lb_listener_rule" {
  count   = var.codedeploy == true ? 0 : 1

  listener_arn       = var.lb_dev_listener_arn
  #priority          = 99

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lb_target_group[0].arn}"
  }

  condition {
    host_header {
      values = ["${var.domain}"]
    }
  }
}
