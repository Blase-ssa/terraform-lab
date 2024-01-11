@echo off
REM format, init, test and aply
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply -auto-approve

@REM ## connect to kubernetes cluster
@REM cd other\load_kubernetes_config
@REM terraform init
@REM terraform apply -auto-approve