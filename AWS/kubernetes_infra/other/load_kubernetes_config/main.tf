## script to configure local kubectl

terraform {
  required_version = ">= 1.6.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "= 3.2.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.21.1"
    }
  }
}

variable "kubeconfig_path" {
  description = "Path to store Kubernetes config file"
  type        = string
  default     = "~/.kube/config"
}

# data "terraform_remote_state" "root" {
#   backend = "local"
#   config = {
#     path = "../../terraform.tfstate"
#   }
# }

variable "aws_region" {
  description = "AWS region."
  type        = string
  # default     = data.terraform_remote_state.root.aws_eks_cluster.region
}

variable "aws_cluster_name" {
  description = "Cluster name."
  type        = string
  # default     = data.terraform_remote_state.root.aws_eks_cluster.name
}

resource "null_resource" "set_aws_kube_config" {
  provisioner "local-exec" {
    # when = create
    command = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.aws_cluster_name} --kubeconfig ${var.kubeconfig_path}"
  }
}
