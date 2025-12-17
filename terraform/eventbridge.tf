########################################
# EventBridge Rule - Daily Trigger
########################################
resource "aws_cloudwatch_event_rule" "daily_cost_trigger" {
  name                = "daily-cost-collector-trigger"
  description         = "Runs cost collector Lambda once per day"
  schedule_expression = "rate(1 day)"
}

########################################
# EventBridge Target - Lambda
########################################
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_cost_trigger.name
  target_id = "CostCollectorLambda"
  arn       = aws_lambda_function.cost_collector.arn
}

########################################
# Permission for EventBridge to invoke Lambda
########################################
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_collector.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_cost_trigger.arn
}
