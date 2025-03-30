module "ecs_bucket_dev" {
  count  = var.env == "Development" ? 1 : 0

  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "ecs-${local.cluster_name}-fargate-dev"
  acl    = "private"

  versioning = {
    enabled = false
  }
}

module "ecs_bucket_prod" {
  count  = var.env == "Production" ? 1 : 0

  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "ecs-${local.cluster_name}-fargate-prod"
  acl    = "private"

  versioning = {
    enabled = false
  }
}

#module "cdn_bucket" {
#
#  source = "terraform-aws-modules/s3-bucket/aws"
#
#  bucket = "cloud${var.env}"
#  acl    = "private"
#
#  versioning = {
#    enabled = false
#  }
#}
