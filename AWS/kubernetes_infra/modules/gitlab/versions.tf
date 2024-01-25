terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.0"
    }

    # }
    # null = {
    #   source  = "hashicorp/null"
    #   version = "= 3.2.1"
    # }
    # random = {
    #   source  = "hashicorp/random"
    #   version = "= 3.5.1"
    # }
  }
}