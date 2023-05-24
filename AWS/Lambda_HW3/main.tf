terraform {
  backend "s3" {
    region = "us-east-1"
    bucket = "luxoft-academy-serverless-tf-state"
    key    = "sergei-silantev"
  }
}

locals {
  tag    = "sergei-silantev"
  region = "us-east-1"
  domain = "serverless.luxoft.academy"
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
  name               = "${local.tag}-lambda1"
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

data "aws_ssm_parameter" "bucket_name" {
  name = "/serverless/s3_bucket"
}

data "aws_s3_bucket" "this" {
  bucket = data.aws_ssm_parameter.bucket_name.value
}

resource "aws_iam_policy" "s3_access" {
  name   = "${local.tag}-s3-access"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
            "s3:*"
      ],
      "Resource": ["${data.aws_s3_bucket.this.arn}", "${data.aws_s3_bucket.this.arn}/*"],
      "Effect": "Allow"
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

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.lambda1.name
  policy_arn = aws_iam_policy.s3_access.arn
}

data "archive_file" "lambda1" {
  type        = "zip"
  source_file = "${path.module}/files/lambda1.py"
  output_path = "${path.module}/files/lambda1.zip"
}

resource "aws_lambda_function" "lambda1" {
  role             = aws_iam_role.lambda1.arn
  function_name    = "${local.tag}-lambda1"
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
  environment {
    variables = {
      S3_BUCKET = data.aws_ssm_parameter.bucket_name.value
      S3_KEY    = local.tag
    }
  }
}

resource "aws_lambda_event_source_mapping" "this" {
  event_source_arn = aws_sqs_queue.this.arn
  function_name    = aws_lambda_function.lambda2.function_name
  enabled          = true
}


data "archive_file" "lambda3" {
  type        = "zip"
  source_file = "${path.module}/files/lambda3.py"
  output_path = "${path.module}/files/lambda3.zip"
}

resource "aws_lambda_function" "lambda3" {
  role             = aws_iam_role.lambda1.arn
  function_name    = "${local.tag}-lambda3"
  runtime          = "python3.9"
  filename         = data.archive_file.lambda3.output_path
  handler          = "lambda3.lambda_handler"
  source_code_hash = data.archive_file.lambda3.output_base64sha256
  environment {
    variables = {
      S3_BUCKET = data.aws_ssm_parameter.bucket_name.value
      S3_KEY    = local.tag
    }
  }
}

resource "aws_apigatewayv2_api" "this" {
  protocol_type = "HTTP"
  name          = local.tag
}

resource "aws_apigatewayv2_integration" "this" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  payload_format_version = "2.0"
  integration_uri        = aws_lambda_function.lambda3.invoke_arn
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_cloudwatch_log_group" "api" {
  name = "/aws/serverless/${local.tag}"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api.arn
    format = jsonencode(
      {
        httpMethod        = "$context.httpMethod"
        ip                = "$context.identity.sourceIp"
        protocol          = "$context.protocol"
        requestId         = "$context.requestId"
        requestTime       = "$context.requestTime"
        responseLength    = "$context.responseLength"
        routeKey          = "$context.routeKey"
        status            = "$context.status"
        integration_error = "$context.integration.error"
      }
    )
  }
}


resource "aws_lambda_permission" "allow_api" {
  statement_id  = "AllowExecutionFromAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda3.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*"
}

data "aws_route53_zone" "zone" {
  name = local.domain
}

data "aws_acm_certificate" "cert" {
  domain      = local.domain
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "aws_apigatewayv2_domain_name" "this" {
  domain_name = "${local.tag}.${local.domain}"

  domain_name_configuration {
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
    certificate_arn = data.aws_acm_certificate.cert.arn
  }
}

resource "aws_apigatewayv2_api_mapping" "this" {
  domain_name = aws_apigatewayv2_domain_name.this.domain_name
  api_id      = aws_apigatewayv2_api.this.id
  stage       = aws_apigatewayv2_stage.this.name
}

resource "aws_route53_record" "this" {
  name    = aws_apigatewayv2_domain_name.this.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.zone.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.this.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.this.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

output "input_url" {
  value = aws_lambda_function_url.lambda1.function_url
}
output "output_url" {
  value = "https://${aws_apigatewayv2_domain_name.this.domain_name}"
}