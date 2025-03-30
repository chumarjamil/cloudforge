terraform {
  required_providers {
    aws = {
      configuration_aliases = [ aws.main, aws.route53 ]
    }
  }
}
