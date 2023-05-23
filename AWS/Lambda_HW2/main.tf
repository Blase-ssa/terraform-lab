terraform {
  backend "s3" {
    region = "us-east-1"
    bucket = "luxoft-academy-serverless-tf-state"
    key    = "sergei-silantev"
  }
}

locals {
  tag    = "sergei-silantev"
  id     = "lambda1"
  region = "us-east-1"
}

provider "aws" {
  region = local.region
  default_tags {
    tags = {
      Owner = local.tag
    }
  }
}

resource "aws_iam_role" "lambda1" {
  name               = "${local.tag}-${local.id}"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Sid": "",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        }
    }

    ]
}
EOF
}

resource "aws_iam_policy" "sqs_access" {
  name = "${local.tag}-sqs-access"
  // full access to this sqs queue 
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
            "sqs:*"
      ],
      "Resource": "${aws_sqs_queue.this.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF 
}

resource "aws_iam_role_policy_attachment" "basic_lambda1" {
  role       = aws_iam_role.lambda1.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "sqs_access" {
  role       = aws_iam_role.lambda1.name
  policy_arn = aws_iam_policy.sqs_access.arn
}

data "archive_file" "lambda1" {
  type        = "zip"
  source_file = "${path.module}/files/lambda1.py"
  output_path = "${path.module}/files/lambda1.zip"
}

resource "aws_lambda_function" "lambda1" {
  role             = aws_iam_role.lambda1.arn
  function_name    = "${local.tag}-${local.id}"
  runtime          = "python3.9"
  filename         = data.archive_file.lambda1.output_path
  handler          = "lambda1.lambda_handler"
  source_code_hash = data.archive_file.lambda1.output_base64sha256

  environment {
    variables = {
      SQS_URL = aws_sqs_queue.this.url
    }
  }
}

resource "aws_lambda_function_url" "lambda1" {
  function_name      = aws_lambda_function.lambda1.function_name
  authorization_type = "NONE"

}

output "url" {
  value = aws_lambda_function_url.lambda1.function_url
}

resource "aws_sqs_queue" "this" {
  name = "${local.tag}-main"
  tags = {
    Name = local.tag
  }
}

data "archive_file" "lambda2" {
  type        = "zip"
  source_file = "${path.module}/files/lambda2.py"
  output_path = "${path.module}/files/lambda2.zip"
}

resource "aws_lambda_function" "lambda2" {
  role             = aws_iam_role.lambda1.arn
  function_name    = "${local.tag}-lambda2"
  runtime          = "python3.9"
  filename         = data.archive_file.lambda2.output_path
  handler          = "lambda2.lambda_handler"
  source_code_hash = data.archive_file.lambda2.output_base64sha256
}

resource "aws_lambda_event_source_mapping" "this" {
  event_source_arn = aws_sqs_queue.this.arn
  function_name    = aws_lambda_function.lambda2.function_name
  enabled          = true
}
