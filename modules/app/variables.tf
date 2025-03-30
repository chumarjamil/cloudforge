variable "cluster_name" {
  description = "Cluster Name"
  type        = string
  default     = "cloud"
}

variable "env" {
  description = "Environment"
  type        = string
}

variable "service_discovery_type" {
  description = "Service Discovery Type, 'http' or 'private_dns'"
  # http: service discovery without dns - tested not stable yet
  # private_dns: service discovery with private dns - tested stable
  type        = string
  default     = "private_dns"
}

variable "namespace_arn" {
  description = "CloudMap Namespace ARN For HTTP Service Discovery"
  type        = string
}

variable "namespace_id" {
  description = "CloudMap Namespace ARN For Private DNS Service Discovery"
  type        = string
}

variable "name" {
  description = "Name of the lb target group."
  type        = string
}

variable "port" {
  description = "Port of the lb target group."
  type        = number
}

variable "cpu" {
  description = "CPU of Task Definition"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "CPU of Task Definition"
  type        = string
  default     = "512"
}

variable "vpc_id" {
  description = "VPC_ID of the lb target group" 
  type        = string
}

variable "health_check_path" {
  description = "Health Check Path" 
  type        = string
  default     = "/"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR Block" 
  type        = string
}

variable "vpc_public_subnets" {
  description = "VPC public subnets" 
  type        = list
  default     = []
}

variable "vpc_private_subnets" {
  description = "VPC private subnets" 
  type        = list
}

variable "domain" {
  description = "Domain name of the lb target group" 
  type        = string
}

variable "codedeploy" {
  description = "Include/Exclude CodeDeploy" 
  type        = bool
  default     = false
}

variable "task_execution_role_arn" {
  description = "Task Definition Role"
  type        = string
}

variable "task_role_arn" {
  description = "Task Definition Role"
  type        = string
}

variable "container_image" {
  description = "ECR Repository image"
  type        = string
}

variable "container_port_name" {
  description = "Task Definition Container Definition Port Name"
  type        = string
  default     = "http"
}

variable "lb_dev_listener_arn" {
  description = "Development LB Listener ARN"
  type        = string
  default     = ""
}

variable "lb_target_group_health_check_status_code" {
  description = "Development LB Listener ARN"
  type        = string
  default     = "200,403"
}

variable "acm_certificate_arn" {
  description = "ACM Certificate ARN"
  type        = string
}

variable "service_desired_count" {
  description = "ECS Service Desired Count"
  type        = number
  default     = 1
}

variable "ecs_codedeploy_role_arn" {
  description = "IAM Role for ECS"
  type        = string
  default     = ""
}
