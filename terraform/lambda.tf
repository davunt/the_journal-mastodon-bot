data "archive_file" "lambda_zip" {
  type             = "zip"
  source_dir       = "../python/"
  output_file_mode = "0666"
  output_path      = "../output/index.zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  # must run generate_layer.sh to create layer
  filename   = "../layer/lambda_layer.zip"
  layer_name = "${var.bot_name}_layer"

  compatible_runtimes = ["python3.9"]
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.bot_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "masto_bot" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = var.bot_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.handler"
  timeout       = 30

  layers = [aws_lambda_layer_version.lambda_layer.arn]

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)

  runtime = "python3.9"

  environment {
    variables = {
      feed_url           = var.feed_url
      masto_api_base_url = var.masto_api_base_url
      masto_access_token = var.masto_access_token
    }
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.bot_name}_lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
