#!/bin/bash

## format, init, test and aply
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
# terraform plan -out tf.plan
# terraform apply "tf.plan"

# ## connect to kubernetes cluster
# cd other/load_kubernetes_config
# terraform init
# terraform apply -auto-approve