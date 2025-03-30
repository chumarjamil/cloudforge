resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/${local.cluster_name}-fargate"

  tags = {
    Environment = var.env
  }
}
