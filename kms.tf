resource "aws_kms_key" "ecs_kms" {
  description             = "KMS key for log ecs cluster"
}

resource "aws_kms_alias" "ecs_kms" {
  name          = "alias/${var.cluster_name}ECSKey"
  target_key_id = aws_kms_key.ecs_kms.key_id
}
