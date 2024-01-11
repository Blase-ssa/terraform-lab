# AWS Kubernetes infra
This repository contains my Terraform scripts to raise Kubernetes infrastructure in AWS

## Story
At the moment I want to improve my understanding of Kubernetes and try things that are difficult to reproduce in minikube. So I created a simple Terraform project consisting of modules, which allows me to raise and destroy infrastructure quite quickly and flexibly. Thanks to this I can test various features of AWS, Kubernetes and software installed in Kubernetes cluster much faster.

## Usage
* Install:
    * Terraform - https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
    * AWS CLI - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
    * kubectl - https://kubernetes.io/docs/tasks/tools/
* Create a user in AWS (AIM) with the ability to use AWS API (in AWS "Console access" means access to the web interface, to access the API it is enough to create an "Access key"). It is also necessary to give the user the appropriate rights.
* Connect to AWS via CLI using the command:
```sh
aws configure
```
* Edit `variables.tf` to set you infrastructure configuration
* Edit `main.tf` to disable or enable modules
* Raise the infrastructure:

```sh
terraform init # to init Terraform 
terraform plan # to verify code and check what will be applied
terraform apply # to apply script 
```


## Files tree
```sh
..
├── README.md               # this readme
├── create_and_connect.cmd  # windows command line script to apply create infrastructure
├── create_and_connect.sh   # Linux command line script to apply create infrastructure
├── destroy_and_clean.cmd   # windows command line script to destroy infrastructure and clean local PC
├── destroy_and_clean.sh    # Linux command line script to destroy infrastructure and clean local PC
├── main.tf                 # root module terraform main file
├── output.tf               # the list of outputs
├── variables.tf            # variables for the project
├── versions.tf             # terraform providers
├── modules                 # this directory contains terraform modules
│   ├── elasticsearch
│   ├── gitlab
│   │   ├── main.tf
│   │   ├── output.tf
│   │   ├── variables.tf
│   │   └── versions.tf
│   ├── grafana
│   ├── influxdb
│   └── kubernetes
│       ├── main.tf
│       ├── output.tf
│       ├── variables.tf
│       └── versions.tf
└── other                   # additional modules or scripts
    ├── get_vpc_info
    │   ├── aws_vpc_info.json
    │   ├── main.tf
    └── load_kubernetes_config
        └── main.tf
```