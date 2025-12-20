########################################
# API Gateway REST API
########################################
resource "aws_api_gateway_rest_api" "cost_api" {
  name        = "cloud-cost-api"
  description = "Read-only API for AWS cost data"
}
########################################
# /costs resource
########################################
resource "aws_api_gateway_resource" "costs" {
  rest_api_id = aws_api_gateway_rest_api.cost_api.id
  parent_id   = aws_api_gateway_rest_api.cost_api.root_resource_id
  path_part   = "costs"
}
########################################
# GET /costs
########################################
resource "aws_api_gateway_method" "get_costs" {
  rest_api_id   = aws_api_gateway_rest_api.cost_api.id
  resource_id   = aws_api_gateway_resource.costs.id
  http_method   = "GET"
  authorization = "NONE"
}
########################################
# Lambda integration
########################################
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.cost_api.id
  resource_id = aws_api_gateway_resource.costs.id
  http_method = aws_api_gateway_method.get_costs.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.cost_reader.invoke_arn
}
########################################
# Permission for API Gateway to invoke Lambda
########################################
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_reader.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.cost_api.execution_arn}/*/*"
}
########################################
# API Deployment
########################################
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.cost_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.costs.id,
      aws_api_gateway_method.get_costs.id,
      aws_api_gateway_integration.lambda_integration.id
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]
}
########################################
# API Gateway Stage
########################################
resource "aws_api_gateway_stage" "dev_stage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.cost_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}
