# Homework: Luxoft academy - Deploying Serverless Application on AWS with Terraform

## Task

Create terraform script to upload simple python script in AWS Lambda.
Use block "local" to create few variables, and check what happens if use this variables before and after this block.
Also try to use variable as ID. like this:

```
resource "aws_iam_role" local.id {
}
```

Use block "output" to get URL.
