variable "aws_region" {
  description = "AWS region."
  type        = string
  # default     = "eu-north-1"
  # default     = "eu-central-1"
  # default     = "us-west-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  # default     = "dev"
  validation {
    condition     = can(regex("dev", var.environment)) || can(regex("test", var.environment)) || can(regex("prod", var.environment))
    error_message = "Environment should be \"dev\", \"test\", \"prod\" or contain \"dev\", \"test\", \"prod\" as a part of name"
  }
}

variable "domain_primary_zone" {
  description = "Domain you own."
  type        = map(string)
  #   default = {
  #     domain = "blase-infra.click"
  #     id     = "Z101155419KLTASVLU3J"
  #   }
}

variable "aws_cluster_name" {
  description = "Kubernetes cluster name."
  type        = string
  # default     = "kubernetes"
}

variable "vpc_id" {
  description = <<EOT
  VPC network ID. 
  To get the ID open 'other\get_vpc_info' and run `terraform apply -auto-approve`. 
  The result will be displayed on the screen and saved to the file 'aws_vpc_info.json'.
  EOT
  type        = string
  # default     = "vpc-04c40bb555cf4d53e"
}

variable "subnet_newbits" {
  description = <<EOT
  "newbits" for cidrsubnet() used to create networks for kubernetes cluster.
  cidrsubnet calculates a subnet address within given IP network address prefix.
  usage:
    cidrsubnet(prefix, newbits, netnum)
  more info here:
  https://developer.hashicorp.com/terraform/language/functions/cidrsubnet
  EOT
  type        = string
  default     = "8"
}
