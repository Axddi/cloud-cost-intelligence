########################################
# CloudWatch Log Group for Lambda
########################################
resource "aws_cloudwatch_log_group" "cost_collector_logs" {
  name              = "/aws/lambda/cloud-cost-collector"
  retention_in_days = 7
}
