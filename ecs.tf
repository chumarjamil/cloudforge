module "ecs_fargate_spot" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.2"

  count = var.env == "Development" ? 1 : 0

  cluster_name =  local.cluster_name

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      kms_key_id = aws_kms_key.ecs_kms.arn
      log_configuration = {
        cloud_watch_log_group_name = "/ecs/${local.cluster_name}-fargate"
        s3_bucket_name = var.env == "Development" ? module.ecs_bucket_dev[0].s3_bucket_id : module.ecs_bucket_prod[0].s3_bucket_id
        s3_key_prefix = "exec-output"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 0
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  tags = {
    Environment = var.env
  }

}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.2"

  count = var.env == "Production" ? 1 : 0

  cluster_name =  local.cluster_name

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      kms_key_id = aws_kms_key.ecs_kms.arn
      log_configuration = {
        cloud_watch_log_group_name = "/ecs/${local.cluster_name}-fargate"
        s3_bucket_name = var.env == "Development" ? module.ecs_bucket_dev[0].s3_bucket_id : module.ecs_bucket_prod[0].s3_bucket_id
        s3_key_prefix = "exec-output"
      }
    }
  }

  tags = {
    Environment = var.env
  }

}
