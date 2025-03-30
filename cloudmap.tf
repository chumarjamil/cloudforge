resource "aws_service_discovery_http_namespace" "ecs" {
  count       = var.service_discovery_type == "http" ? 1 : 0

  name        = var.cluster_name
  description = "Private namespace for ECS"
}

resource "aws_service_discovery_private_dns_namespace" "ecs" {
  count       = var.service_discovery_type == "private_dns" ? 1 : 0

  name        = var.cluster_name
  description = "Private namespace for ECS"
  vpc         = module.vpc.vpc_id
}
