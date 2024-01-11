## script to get vpc info

terraform {
  required_version = ">= 1.6.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31.0"
    }
    local = {
      source = "hashicorp/local"
      version = ">= 2.4.0"
    }
  }
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-north-1"
  # default     = "eu-central-1"
  # default     = "us-west-1"
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "main_cidr" {
}

resource "local_file" "aws_vpc_info" {
  filename = "aws_vpc_info.json"
  content  = jsonencode(data.aws_vpc.main_cidr)
}

output "aws_vpc_info" {
  description = "VPC info"
  value       = data.aws_vpc.main_cidr
}