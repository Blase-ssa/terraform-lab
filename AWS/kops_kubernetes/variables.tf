variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-north-1"
  # default     = "eu-central-1"
  # default     = "us-west-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
  validation {
    condition     = can(regex("dev", var.environment)) || can(regex("test", var.environment)) || can(regex("prod", var.environment))
    error_message = "Environment should be \"dev\", \"test\", \"prod\" or contain \"dev\", \"test\", \"prod\" as a part of name"
  }
}

variable "domain_primary_zone" {
  description = "Domain you own."
  type        = map(string)
  default = {
    domain = "blase-infra.click"
    id     = "Z101155419KLTASVLU3J"
  }
}

variable "kubernetes_domain_prefix" {
  description = "Prefix used to create FQDN for kubernetes."
  type        = string
  default     = "kops"
}
variable "kubernetes_node_count" {
  description = "Kubernetes node count"
  default     = 2
}

variable "kubernetes_node_type" {
  description = "value"
  default     = "t3.micro"
  #default     = "t2.micro"
  #default     = "t4g.small"
}