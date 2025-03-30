output "name" {
  description = "Name (id) of the lb target group"
  value       = var.name
}

output "domain" {
  description = "Domain name of the lb target group"
  value       = var.domain
}

output "alb_endpoint" {
  description = "ALB Endpoint"
  value       = var.codedeploy == true ? aws_lb.alb[0].dns_name : null
}
