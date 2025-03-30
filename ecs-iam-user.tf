resource "aws_iam_user" "ecs" {
  name = "ecs-user"
  path = "/"

  tags = {
    Environment = var.env
  }
}

resource "aws_iam_access_key" "ecs" {
  user = aws_iam_user.ecs.name
}

resource "aws_iam_user_policy" "ecs_register_task_definition" {
  name = "ECSAccess"
  user = aws_iam_user.ecs.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "ecs:RegisterTaskDefinition",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "key_management_custom_access" {
  name        = "KeyManagementServiceCustomAccess"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_user_policy_attachment" "attach_secrets_manager" {
  user       = aws_iam_user.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_user_policy_attachment" "attach_ecs_fullaccess" {
  user       = aws_iam_user.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_user_policy_attachment" "attach_cloudwatch_fullaccess" {
  user       = aws_iam_user.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_user_policy_attachment" "attach_task_execution_attach_ecr" {
  user       = aws_iam_user.ecs.name
  policy_arn = aws_iam_policy.ecr_full_access.arn
}

resource "aws_iam_user_policy_attachment" "attach_key_management_custom_access" {
  user       = aws_iam_user.ecs.name
  policy_arn = aws_iam_policy.key_management_custom_access.arn
}
