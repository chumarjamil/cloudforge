output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "ECS Cluster Name"
  value       = local.cluster_name
}

output "public_connection_string_bastion_host" {
  description = "Copy/Paste/Enter - You are in the matrix"
  value       = "ssh -i ${var.key_name} ubuntu@${aws_instance.bastion_host.public_ip} -p ${var.bastion_port}"
}

output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = module.rds[0].db_instance_endpoint
}

output "rds_replica_endpoint" {
  description = "RDS Replica Endpoint"
  value       = var.env == "Production" ? aws_db_instance.replica[0].endpoint : null
}

output "rds_password" {
  description = "RDS Password"
  value       = module.rds[0].db_instance_password
  sensitive = true
}

output "rds_sonarqube_endpoint" {
  description = "RDS Sonarqube Endpoint"
  value       = var.include_sonarqube == true ? aws_db_instance.sonarqube[0].endpoint : null
}

output "rds_sonarqube_username" {
  description = "RDS Sonarqube Usernmae"
  value       = var.include_sonarqube == true ? aws_db_instance.sonarqube[0].username : null
}

output "rds_sonarqube_password" {
  description = "RDS Sonarqube Password"
  value       = var.include_sonarqube == true ? var.rds_sonarqube_password : null
  sensitive   = true
}

output "rds_sonarqube_db_name" {
  description = "RDS Sonarqube Database Name"
  value       = var.include_sonarqube == true ? var.rds_sonarqube_db_name : null
}

output "efs_sonarqube_filesystem_id" {
  description = "EFS FileSystem ID"
  value       = var.include_sonarqube == true ? aws_efs_file_system.sonarqube[0].id : null
}

output "efs_sonarqube_accesspoint_id" {
  description = "EFS AccessPoint ID"
  value       = var.include_sonarqube == true ? aws_efs_mount_target.sonarqube[0].id : null
}

output "ecs_task_execution_role_arn" {
  description = "ECS TaskExecutionRole"
  value       = aws_iam_role.task_execution_role.arn
}

output "private_key" {
  value     = tls_private_key.bastion_key.private_key_pem
  sensitive = true
}

output "endpoint_alb_development" {
  description = "Endpoint ALB Development"
  value       = var.env == "Development" ? aws_lb.alb[0].dns_name : null
}

output "ecs_user_id" {
  value = aws_iam_access_key.ecs.id
}

output "ecs_user_secret" {
  value     = aws_iam_access_key.ecs.secret
  sensitive = true
}

output "ecs_user_keys" {
  value = aws_iam_access_key.ecs.encrypted_secret
}

output "fe_user_id" {
  value = aws_iam_access_key.fe.id
}

output "fe_user_secret" {
  value     = aws_iam_access_key.fe.secret
  sensitive = true
}

output "fe_user_keys" {
  value = aws_iam_access_key.fe.encrypted_secret
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.ecs_log_group.arn
}

output "aws_kms_key" {
  value = aws_kms_key.ecs_kms.arn
}

output "aws_kms_alias" {
  value = aws_kms_alias.ecs_kms.arn
}
