variable "cluster_name" {
  description = "Cluster Name"
  type        = string
  default     = "cloud"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "service_discovery_type" {
  description = "Service Discovery Type, 'http' or 'private_dns'"
  # http: service discovery without dns - tested not stable yet
  # private_dns: service discovery with private dns - tested stable
  type        = string
  default     = "private_dns"
}

variable "aws_access_key" {
  type        = string
}

variable "aws_secret_key" {
  type        = string
}

variable "aws_session_token" {
  type        = string
}

variable "aws_access_key_common" {
  type        = string
}

variable "aws_secret_key_common" {
  type        = string
}

variable "aws_session_token_common" {
  type        = string
}

variable "env" {
  description = "Environment"
  type        = string
}

variable "rds-name" {
  type        = string
  default     = "cloud"
}

variable "rds-db-name" {
  type        = string
  default     = "cloud_live"
}

##SONARQUBE
variable "include_sonarqube" {
  type        = bool
}

variable "rds_sonarqube_name" {
  type        = string
  default     = "sonarqube"
}

variable "rds_sonarqube_db_name" {
  type        = string
  default     = "sonarqube"
}

variable "rds_sonarqube_password" {
  type        = string
}

variable "rds_sonarqube_username" {
  type        = string
  default     = "sonarqube"
}

variable "sonarqube_efs_accesspoint_id" {
  default     = "fsap-06a42e962b94cb215"
  type        = string
}

##DATABASE
variable "include_db_module" {
  default     = true
  type        = bool
}

variable "include_db_replica" {
  type        = bool
}

variable "bastion_hostname" {
  type        = string
  description = "Server hostname"
  default     = "cloud"
}

variable "bastion_port" {
  type        = string
  default     = "54121"
}

variable "key_name" {
  type        = string
  default     = "cloud"
}

variable "acm_certificate_arn" {
  type        = string
}

variable "codedeploy" {
  description = "Map of codedeploy app and group"
  type        = map(any)
  default = {
    cloud-infra = {
      app_name              = "cloud-infra"
      group_name            = "cloud-infra-dg"
    }  
  }
}

### Route53 Domain Zone ID
variable "domain_zone_id" {
  type        = string
  default     = "Z09909413TZ80OATTT3O5"
}

### AWS Account ID
variable "aws_production_id" {
  type        = string
}

variable "aws_development_id" {
  type        = string
}

variable "aws_common_id" {
  type        = string
}

### CDN
variable "is_cdn_role_created" {
  type        = bool
  default     = true
}

variable "cdn_development_groups" {
  type        = map(any)
  default = {
    development = {
      domains          = ["test-cdn-dev.test.com"]
      cloudfront_name  = "cdn-development"
      origin_bucket    = "test-cdn-fe-dev"
      default_ttl      = 300
    }
  }
}

variable "cdn_production_groups" {
  type        = map(any)
  default = {
    production = {
      domains          = ["test-cdn-prod.test.com", "test3-cdn-prod.test.com"]
      cloudfront_name  = "cdn-production"
      origin_bucket    = "test-cdn-fe-prod"
      default_ttl      = 300
    }
  }
}
