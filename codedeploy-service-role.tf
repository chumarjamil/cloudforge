resource "aws_iam_role" "ecs_codedeploy_role" {
  count   = var.env == "Production" ? 1 : 0

  name    = "ecsCodeDeployRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_codedeploy_role_attach" {
  count   = var.env == "Production" ? 1 : 0

  role       = aws_iam_role.ecs_codedeploy_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}
