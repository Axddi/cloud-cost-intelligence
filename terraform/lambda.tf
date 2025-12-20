########################################
# Package Lambda source code
########################################
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../lambda/cost_collector"
  output_path = "../lambda/cost_collector.zip"
}

########################################
# Lambda Function: Cloud Cost Collector
########################################
resource "aws_lambda_function" "cost_collector" {
  function_name = "cloud-cost-collector"

  runtime = "python3.11"
  handler = "handler.lambda_handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.lambda_cost_role.arn

  timeout = 30

environment {
  variables = {
    ENV             = "dev"
    TABLE_NAME      = aws_dynamodb_table.cost_table.name
    SNS_TOPIC_ARN   = aws_sns_topic.cost_alerts.arn
    DAILY_THRESHOLD = "5"
  }
}

}

########################################
# Package Cost Reader Lambda
########################################
data "archive_file" "cost_reader_zip" {
  type        = "zip"
  source_dir  = "../lambda/cost_reader"
  output_path = "../lambda/cost_reader.zip"
}
########################################
# Cost Reader Lambda Function
########################################
resource "aws_lambda_function" "cost_reader" {
  function_name = "cloud-cost-reader"

  runtime = "python3.11"
  handler = "handler.lambda_handler"

  filename         = data.archive_file.cost_reader_zip.output_path
  source_code_hash = data.archive_file.cost_reader_zip.output_base64sha256

  role = aws_iam_role.lambda_cost_role.arn

  timeout = 10

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.cost_table.name
    }
  }
}
