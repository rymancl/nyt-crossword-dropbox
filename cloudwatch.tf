# RULES
resource "aws_cloudwatch_event_rule" "weekday" {
  name                = "${local.name}-weekday"
  description         = "Fires every weekday at 10:01 PM ET"
  schedule_expression = "cron(1 22 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_rule" "weekend" {
  name                = "${local.name}-weekend"
  description         = "Fires every weekend at 6:01 PM ET"
  schedule_expression = "cron(1 18 ? * SAT-SUN *)"
}


# TARGETS
resource "aws_cloudwatch_event_target" "weekday" {
  rule      = aws_cloudwatch_event_rule.weekday.name
  target_id = aws_cloudwatch_event_rule.weekday.name
  arn       = aws_lambda_function.downloader.arn
}

resource "aws_cloudwatch_event_target" "weekend" {
  rule      = aws_cloudwatch_event_rule.weekend.name
  target_id = aws_cloudwatch_event_rule.weekend.name
  arn       = aws_lambda_function.downloader.arn
}
