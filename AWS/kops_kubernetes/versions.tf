terraform {
  required_version = ">= 1.6.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.31.0"
    }
    null = {
      # Needed to execute commands locally.
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
    random = {
      # Needed to generate random numbers.
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
    local = {
      # Needed to create a local file.
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
  }
}