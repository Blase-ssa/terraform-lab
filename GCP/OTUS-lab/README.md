# GCP terraform lab 1
# Task:

 * Deploy two Linux Virtual Machines with dependencies in two different Europe regions (e.g. west and east).
 * Each VM should be accessible by SSH from the public internet.
 * VM 1 should have installed the Nginx server on startup (provisioning), with the basic web page accessible from the public internet
 * VM 2 should be accessible to PING from the public internet.

# How to use
* In linux shell use "ssh-keygen" command to generate key pair
* Go to you Google Cloud Console and download credentials file, place it somewhere outside git repository, than update path in main.tf (in 'provider "google"' block), also update project ID
* Update you user account name (search "user" keyword) and path to secret key file if necessary
* in bash shell navigate to project folder and use commands:
```bash
terraform init # to init Terrafrodm 
terraform plan # to verify code and check what will be applied
terraform apply # to apply script 
```

