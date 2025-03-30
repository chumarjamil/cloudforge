# Creating Amazon EFS File system
resource "aws_efs_file_system" "sonarqube" {
  count = var.include_sonarqube ? 1 : 0

# Creating the AWS EFS lifecycle policy
# Amazon EFS supports two lifecycle policies. Transition into IA and Transition out of IA
# Transition into IA transition files into the file systems's Infrequent Access storage class
# Transition files out of IA storage
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
# Tagging the EFS File system with its value as Sonarqube
  tags = {
    Name = "Sonarqube"
    Environment = var.env
  }
}

# Creating the EFS access point for AWS EFS File system
resource "aws_efs_access_point" "sonarqube" {
  count = var.include_sonarqube ? 1 : 0

  file_system_id = aws_efs_file_system.sonarqube[0].id
}

# Creating the AWS EFS Mount point in a specified Subnet 
# AWS EFS Mount point uses File system ID to launch.
resource "aws_efs_mount_target" "sonarqube" {
  count = var.include_sonarqube ? 1 : 0
  
  file_system_id = aws_efs_file_system.sonarqube[0].id
  subnet_id      = module.vpc.private_subnets[0]
}
