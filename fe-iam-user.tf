# fe = frontend
resource "aws_iam_user" "fe" {
  name = "fe-user"
  path = "/"

  tags = {
    Environment = var.env
  }
}

resource "aws_iam_access_key" "fe" {
  user = aws_iam_user.fe.name
}

resource "aws_iam_policy" "s3_custom_access_policy_development" {
  count       = var.env == "Development" ? 1 : 0

  name        = "S3CustomAccessPolicy"
  description = "IAM policy for S3 access"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for group_key, group_value in var.cdn_development_groups : {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          "arn:aws:s3:::${group_value.origin_bucket}/*",
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "s3_custom_access_policy_production" {
  count       = var.env == "Production" ? 1 : 0

  name        = "S3CustomAccessPolicy"
  description = "IAM policy for S3 access"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for group_key, group_value in var.cdn_production_groups : {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          "arn:aws:s3:::${group_value.origin_bucket}/*",
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "cloudfront_custom_access_policy" {
  count       = var.env == "Production" ? 1 : 0

  name        = "CloudFrontCustomAccessPolicy"
  description = "IAM policy for S3 access"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for cdn_key, cdn in module.cdn : {
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation"]
        Resource = [
          "${cdn.arn}",
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_s3_custom_access_development" {
  count       = var.env == "Development" ? 1 : 0

  user       = aws_iam_user.fe.name
  policy_arn = aws_iam_policy.s3_custom_access_policy_development[0].arn
}

resource "aws_iam_user_policy_attachment" "attach_s3_custom_access_production" {
  count       = var.env == "Production" ? 1 : 0

  user       = aws_iam_user.fe.name
  policy_arn = aws_iam_policy.s3_custom_access_policy_production[0].arn
}

resource "aws_iam_user_policy_attachment" "attach_cloudfront_custom_access" {
  count       = var.env == "Production" ? 1 : 0

  user       = aws_iam_user.fe.name
  policy_arn = aws_iam_policy.cloudfront_custom_access_policy[0].arn
}
