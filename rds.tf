module "rds" {
  count       = var.include_db_module ? 1 : 0

  source      = "terraform-aws-modules/rds/aws"

  identifier  = var.rds-name

  engine            = "mysql"
  engine_version    = "8.0.28"
  instance_class    = "db.t4g.micro"
  allocated_storage = 5

  db_name   = var.rds-db-name
  username  = "admin"
  port      = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids      = [aws_security_group.rds.id]

  backup_retention_period     = var.env == "Production" ? 5 : 0
  backup_window               = "03:00-06:00"
  auto_minor_version_upgrade  = false

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval       = "30"
  monitoring_role_name      = "MyRDSMonitoringRole"
  create_monitoring_role    = true

  tags = {
    Environment = var.env
  }

  # DB subnet group
  db_subnet_group_name      = aws_db_subnet_group.db-subnet-group.name

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version      = "8.0"

  # Database Deletion Protection
  deletion_protection       = true

  skip_final_snapshot       = true
}

resource "aws_db_instance" "replica" {
  count                   = var.include_db_replica ? 1 : 0

  identifier              = "${var.rds-name}-replica"
  availability_zone       = module.rds[0].db_instance_availability_zone
  publicly_accessible     = true
  replicate_source_db     = module.rds[0].db_instance_id
  instance_class          = "db.t4g.micro"
  skip_final_snapshot     = true
  multi_az                = false
  deletion_protection     = false
  vpc_security_group_ids  = [aws_security_group.rds_public[0].id]
  backup_retention_period = 5
  backup_window           = "03:00-06:00"
  storage_encrypted       = true
  iam_database_authentication_enabled   = true
}

resource "aws_db_instance" "sonarqube" {
  count = var.include_sonarqube ? 1 : 0

  db_subnet_group_name  = aws_db_subnet_group.db-subnet-group.name
  allocated_storage = 5
  identifier = "sonarqube"
  storage_type = "gp2"
  engine = "postgres"
  instance_class = "db.t4g.micro"
  db_name  = var.rds_sonarqube_db_name
  username = var.rds_sonarqube_username
  password = var.rds_sonarqube_password
  publicly_accessible    = false
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sonarqube[0].id]

  tags = {
    Name = "sonarqube"
    Environment = var.env
  }
}
