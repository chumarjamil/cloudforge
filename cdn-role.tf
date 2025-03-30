resource "aws_iam_role" "route53_access_role_development" {
  count = var.env == "Development" ? 1 : 0

  provider = aws.common
  name = "route53AccessRole${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        "AWS": ["arn:aws:iam::${var.aws_development_id}:root"]
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "route53_access_role_production" {
  count = var.env == "Production" ? 1 : 0

  provider = aws.common
  name = "route53AccessRole${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        "AWS": ["arn:aws:iam::${var.aws_production_id}:root"]
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "route53_access_policy_development" {
  count = var.env == "Development" ? 1 : 0

  provider = aws.common
  name = "route53_access_policy_development"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["route53:ChangeResourceRecordSets", "route53:GetHostedZone", "route53:ListResourceRecordSets"]
        Resource = ["arn:aws:route53:::hostedzone/${var.domain_zone_id}"]
      },
      {
        Effect   = "Allow"
        Action   = [
          "route53:ListHostedZonesByName",
          "route53:ListHostedZones",
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_policy" "route53_access_policy_production" {
  count = var.env == "Production" ? 1 : 0

  provider = aws.common
  name = "route53_access_policy_production"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["route53:ChangeResourceRecordSets", "route53:GetHostedZone", "route53:ListResourceRecordSets"]
        Resource = ["arn:aws:route53:::hostedzone/${var.domain_zone_id}"]
      },
      {
        Effect   = "Allow"
        Action   = [
          "route53:GetChange",
          "route53:ListHostedZonesByName",
          "route53:ListHostedZones",
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "route53_access_policy_attachment_development" {
  count = var.env == "Development" ? 1 : 0

  provider = aws.common
  policy_arn = aws_iam_policy.route53_access_policy_development[0].arn
  role       = aws_iam_role.route53_access_role_development[0].name
}

resource "aws_iam_role_policy_attachment" "route53_access_policy_attachment_production" {
  count = var.env == "Production" ? 1 : 0

  provider = aws.common
  policy_arn = aws_iam_policy.route53_access_policy_production[0].arn
  role       = aws_iam_role.route53_access_role_production[0].name
}
