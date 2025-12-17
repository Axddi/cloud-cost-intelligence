########################################
# Trust policy: Allow Lambda to assume role
########################################
data "aws_iam_policy_document" "lambda_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

########################################
# IAM Role for Cost Collector Lambda
########################################
resource "aws_iam_role" "lambda_cost_role" {
  name               = "lambda-cost-collector-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
}

########################################
# IAM Policy: Cost Explorer read access
########################################
data "aws_iam_policy_document" "cost_explorer_policy" {
  statement {
    effect = "Allow"

    actions = [
      "ce:GetCostAndUsage"
    ]

    resources = ["*"]
  }
}

########################################
# Create IAM Policy
########################################
resource "aws_iam_policy" "cost_policy" {
  name   = "lambda-cost-explorer-policy"
  policy = data.aws_iam_policy_document.cost_explorer_policy.json
}

########################################
# Attach Policy to Lambda Role
########################################
resource "aws_iam_role_policy_attachment" "attach_cost_policy" {
  role       = aws_iam_role.lambda_cost_role.name
  policy_arn = aws_iam_policy.cost_policy.arn
}

########################################
# IAM Policy: CloudWatch Logs access
########################################
data "aws_iam_policy_document" "cloudwatch_logs_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name   = "lambda-cloudwatch-logs-policy"
  policy = data.aws_iam_policy_document.cloudwatch_logs_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_logs_policy" {
  role       = aws_iam_role.lambda_cost_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}
