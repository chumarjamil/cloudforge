variable "bucket_name" {
  type = string
}

variable "domain_zone_id" {
  type = string
}

variable "domains" {
  type    = list(string) 
}

variable "min_ttl" {
  type    = number
}

variable "max_ttl" {
  type    = number
}

variable "default_ttl" {
  type    = number
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

variable "acm_cdn_certificate_arn" {
  type        = string
}

variable "aws_account_id" {
  type        = string
}

variable "s3_username" {
  type        = string
}
