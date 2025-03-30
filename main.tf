provider "aws" {
  region = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token = var.aws_session_token
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = var.cluster_name
}
