########################################
# SNS Topic for Cost Alerts
########################################
resource "aws_sns_topic" "cost_alerts" {
  name = "cloud-cost-alerts"
}

########################################
# SNS Email Subscription
########################################
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
