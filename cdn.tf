provider "aws" {
  alias  = "common"
  region = var.region
  access_key = var.aws_access_key_common
  secret_key = var.aws_secret_key_common
  token = var.aws_session_token_common
}

# Configure Cross Account Role for target account
provider "aws" {
  region     = var.region
  alias      = "route53"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token = var.aws_session_token
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_common_id}:role/route53AccessRole${var.env}"
    session_name = "route53CrossAccount"
  }
}

# Configure Cross Account Role for target account
provider "aws" {
  region  = "us-east-1"
  alias   = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token = var.aws_session_token
}

# Request a whildcard certificate from ACM
resource "aws_acm_certificate" "acm_certificate" {
  provider = aws.us-east-1

  domain_name = "*.test.com"
  subject_alternative_names = ["test.com"]
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
}

# Create record for validate acm request certificate
resource "aws_route53_record" "acm_validation" {
  provider = aws.route53

  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.domain_zone_id
}

# Validate the certificate
resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  provider = aws.us-east-1

  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

# Create CloudFront Distribution
module "cdn" {

  providers = {
    aws.main = aws
    aws.route53 = aws.route53
  }

  for_each          = var.env == "Production" ? var.cdn_production_groups : var.cdn_development_groups
  source            = "./modules/cdn"

  bucket_name       = each.value.origin_bucket
  s3_username       = "fe-user"
  domains           = each.value.domains
  domain_zone_id    = var.domain_zone_id
  default_ttl       = each.value.default_ttl
  min_ttl           = 0
  max_ttl           = 86400 # 1 day
  aws_account_id    = var.env == "Production" ? var.aws_production_id : var.aws_development_id
  aws_session_token = var.aws_session_token
  aws_secret_key    = var.aws_secret_key
  aws_access_key    = var.aws_access_key
  acm_cdn_certificate_arn = aws_acm_certificate.acm_certificate.arn
  
}
