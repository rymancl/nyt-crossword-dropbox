# IAM
resource "aws_iam_role" "lambda" {
  name = "${local.name}-role"

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

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# FUNCTION
data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/${local.name}.zip"
}

resource "aws_lambda_function" "downloader" {
  function_name = "${local.name}-function"
  filename      = "${local.name}.zip"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256(data.archive_file.zip.output_path)

  runtime = "nodejs14.x"

  environment {
    variables = {
      DROPBOX_ACCESS_TOKEN = var.dropbox_token,
      DROPBOX_FILE_PATH    = var.dropbox_path,
      NYT_COOKIE           = local.nyt_cookie_string
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_weekday" {
  statement_id  = "AllowCloudWatchWeekdayTrigger"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.downloader.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.weekday.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_weekend" {
  statement_id  = "AllowCloudWatchWeekendTrigger"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.downloader.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.weekend.arn
}
