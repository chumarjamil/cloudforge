resource "aws_security_group" "rds" {
  name_prefix = "SG-${var.env}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    cidr_blocks = [
       module.vpc.vpc_cidr_block,
    ]
  }
}

resource "aws_security_group" "rds_public" {
  count = var.env == "Production" ? 1 : 0

  name_prefix = "SG-Public-${var.env}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    cidr_blocks = [
       "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group" "rds_sonarqube" {
  count       = var.include_sonarqube ? 1 : 0

  name_prefix = "SG-Sonarqube-${var.env}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    cidr_blocks = [
       module.vpc.vpc_cidr_block,
    ]
  }
}

resource "aws_security_group" "bastion_host_sg" {
  name        = "BastionHost-SG"
  description = "Allow incoming traffic to the Linux EC2 Instance"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = "${var.bastion_port}"
    to_port     = "${var.bastion_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "New SSH Port"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "BastionHost-${var.env}-SG"
    Environment = var.env
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "SG-ALB-${var.env}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sonarqube" {
  count       = var.env == "Development" ? 1 : 0

  name_prefix = "SG-Sonarqube-${var.env}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
       module.vpc.vpc_cidr_block,
    ]
  }

  ingress {
    from_port = 9000
    to_port   = 9000
    protocol  = "tcp"

    cidr_blocks = [
       module.vpc.vpc_cidr_block,
    ]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
