
REM destroy
terraform destroy -auto-approve

REM clean
echo "All Kubernetes configuration files will be deleted, are you sure?"
pause
del /F ~/.kube
