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
      ENV = "dev"
    }
  }
}
