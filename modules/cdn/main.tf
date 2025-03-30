# Create S3 bucket
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { AWS = [aws_cloudfront_origin_access_identity.website_distribution.iam_arn]},
        Action = [
          "s3:GetObject", 
        ],
        Resource = ["${aws_s3_bucket.website_bucket.arn}/*"]
      },
      {
        Effect = "Allow",
        Principal = { AWS = ["arn:aws:iam::${var.aws_account_id}:user/${var.s3_username}"]},
        Action = [
          "s3:ListBucket",
          "s3:GetObject", 
          "s3:PutObject"
        ],
        Resource = ["${aws_s3_bucket.website_bucket.arn}/*", "${aws_s3_bucket.website_bucket.arn}"]
      }
    ]
  })
}

resource "aws_cloudfront_origin_access_identity" "website_distribution" {
  comment = "For bucket ${var.bucket_name}"
}

# Create distribution CloudFront 
resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website_bucket.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website_distribution.cloudfront_access_identity_path
    }
  }

  custom_error_response {
          error_caching_min_ttl = 0
          error_code = 404
          response_code = 200
          response_page_path = "/index.html"
  }

  custom_error_response {
        error_caching_min_ttl = 0
        error_code = 500
        response_code = 500
        response_page_path = "/500.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = [] 
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Website Distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.website_bucket.id
    min_ttl          = var.min_ttl
    max_ttl          = var.max_ttl
    default_ttl      = var.default_ttl

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  # Konfigurasi alias domain dan SSL
  aliases = var.domains

  viewer_certificate {
    acm_certificate_arn = var.acm_cdn_certificate_arn
    ssl_support_method  = "sni-only"
  }
}

# Create record set for domain alias in Route53
resource "aws_route53_record" "website_alias_record" {
  for_each = toset(var.domains)

  provider = aws.route53
  zone_id  = var.domain_zone_id
  name     = each.key
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
