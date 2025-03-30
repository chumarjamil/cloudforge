module "outlet_portal_development" { # use "_" as seperator
  count                   = var.env == "Development" ? 1 : 0
  source                  = "./modules/app"
  env                     = var.env
  service_discovery_type  = "private_dns"
  namespace_arn           = var.service_discovery_type == "http" ? aws_service_discovery_http_namespace.ecs[0].arn : null
  namespace_id            = var.service_discovery_type == "private_dns" ? aws_service_discovery_private_dns_namespace.ecs[0].id : null
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr_block          = module.vpc.vpc_cidr_block
  vpc_private_subnets     = module.vpc.private_subnets
  task_execution_role_arn = aws_iam_role.task_execution_role.arn
  task_role_arn           = aws_iam_role.task_role.arn
  lb_dev_listener_arn     = aws_lb_listener.listener_https[0].arn
  acm_certificate_arn     = var.acm_certificate_arn
  service_desired_count   = 1

  name                    = "outlet-portal"
  container_image         = "088074866799.dkr.ecr.ap-southeast-1.amazonaws.com/outlet-portal:latest"
  port                    = 80
  domain                  = "dev-outlet-portal.test.com"
  health_check_path       = "/health-check.php"
}

module "outlet_portal_production" { # use "_" as seperator
  count                   = var.env == "Production" ? 1 : 0
  source                  = "./modules/app"
  env                     = var.env
  service_discovery_type  = var.service_discovery_type
  namespace_arn           = var.service_discovery_type == "http" ? aws_service_discovery_http_namespace.ecs[0].arn : null
  namespace_id            = var.service_discovery_type == "private_dns" ? aws_service_discovery_private_dns_namespace.ecs[0].id : null
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr_block          = module.vpc.vpc_cidr_block
  vpc_private_subnets     = module.vpc.private_subnets
  vpc_public_subnets      = module.vpc.public_subnets
  task_execution_role_arn = aws_iam_role.task_execution_role.arn
  task_role_arn           = aws_iam_role.task_role.arn
  ecs_codedeploy_role_arn = aws_iam_role.ecs_codedeploy_role[0].arn
  acm_certificate_arn     = var.acm_certificate_arn
  codedeploy              = true
  service_desired_count   = 1

  name                    = "outlet-portal"
  container_image         = "088074866799.dkr.ecr.ap-southeast-1.amazonaws.com/outlet-portal:latest"
  port                    = 80
  domain                  = "outlet-portal.test.com"
  health_check_path       = "/health-check.php"
}

output "outlet_portal_alb_endpoint_production" { # use "_" as seperator
  description = "ALB Endpoint"
  value       = var.env == "Production" ? module.outlet_portal_production[0].alb_endpoint : null  # use "_" as seperator
}