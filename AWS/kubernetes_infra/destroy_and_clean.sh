#!/bin/bash

## destroy
terraform destroy -auto-approve

## clean
echo "All Kubernetes configuration files will be deleted, are you sure?"
pause
rm -rf ~/.kube
