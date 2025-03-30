resource "aws_service_discovery_service" "service_discovery_service" {
  count = var.service_discovery_type == "private_dns" ? 1 : 0

  name  = var.name

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
