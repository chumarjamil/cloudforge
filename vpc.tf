module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = var.env

  cidr = "10.200.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)

  private_subnets = ["10.200.16.0/20", "10.200.48.0/20"]
  public_subnets  = ["10.200.0.0/20", "10.200.32.0/20"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    Environment = var.env
  }

  private_subnet_tags = {
    Environment = var.env
  }

}

resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "db-subnet-group"
  subnet_ids = concat(module.vpc.private_subnets,module.vpc.public_subnets)

  tags = {
    Environment = var.env
  }
}
