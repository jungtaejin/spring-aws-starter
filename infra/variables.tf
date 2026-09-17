variable "project_name" {
  description = "Prefix for every resource name."
  type        = string
  default     = "spring-aws-starter"
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "instance_type" {
  description = "t3.micro / t2.micro are free-tier eligible for 12 months."
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  type    = number
  default = 1
}

variable "asg_max_size" {
  type    = number
  default = 2
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "starter"
}

variable "db_username" {
  type    = string
  default = "starter"
}

variable "db_password" {
  description = "Stored in SSM Parameter Store as a SecureString; never written to user-data or logs."
  type        = string
  sensitive   = true
}

variable "image_tag" {
  description = "Initial image tag the instances pull. The deploy workflow overwrites the SSM parameter afterwards."
  type        = string
  default     = "latest"
}

variable "github_repo" {
  description = "owner/repo allowed to assume the deploy role via GitHub OIDC."
  type        = string
  default     = "jungtaejin/spring-aws-starter"
}
