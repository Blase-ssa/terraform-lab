#!/bin/bash

## format, init, test and aply
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply -auto-approve

# ## connect to kubernetes cluster
# cd other/load_kubernetes_config
# terraform init
# terraform apply -auto-approve