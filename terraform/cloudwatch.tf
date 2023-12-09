resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.bot_name}"
  retention_in_days = 5
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.bot_name}-schedule"
  description         = "Schedule for Lambda Function"
  schedule_expression = "cron(0/30 * * * ? *)" # run every 30 mins
}

resource "aws_cloudwatch_event_target" "schedule_lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "processing_lambda"
  arn       = aws_lambda_function.masto_bot.arn
}


resource "aws_lambda_permission" "allow_events_bridge_to_run_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.masto_bot.function_name
  principal     = "events.amazonaws.com"
}
