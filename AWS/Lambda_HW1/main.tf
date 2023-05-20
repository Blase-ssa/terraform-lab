terraform {
  required_version = ">= 0.12"
  backend "s3" {
    # region = local.region #  Variables may not be used here, becasue it should be declare before using.
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

/* variabels can't be used in block determination area 
resource "aws_iam_role" local.id {
}*/

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

resource "aws_iam_role_policy_attachment" "basic_lambda1" {
  role       = aws_iam_role.lambda1.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda1" {
  type        = "zip"
  output_path = "${path.module}/files/output.zip"

  source {
    dir      = "${path.module}/files/"
    content  = ""
    filename = "*.py"
  }
}

resource "aws_lambda_function" "lambda1" {
  role = aws_iam_role.lambda1.arn
  function_name = "${local.tag}-${local.id}"
  runtime = "python3.9"
  filename = data.archive_file.lambda1.output_path
  handler = "main.lambda_handler"
  source_code_hash = data.archive_file.lambda1.output_base64sha256
}

resource "aws_lambda_url" "lambda1" {
  function_name = aws_lambda_function.lambda1.function_name
  authorization_type = "NONE"
}

output "url" {
  value = aws_lambda_url.lambda1.function_url
}