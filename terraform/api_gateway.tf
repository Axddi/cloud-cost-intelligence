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
    aws_api_gateway_method.options_costs.id,
    aws_api_gateway_integration.lambda_integration.id
  ]))
}
  lifecycle {
    create_before_destroy = true
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
########################################
# OPTIONS /costs (CORS)
########################################
resource "aws_api_gateway_method" "options_costs" {
  rest_api_id   = aws_api_gateway_rest_api.cost_api.id
  resource_id   = aws_api_gateway_resource.costs.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.cost_api.id
  resource_id = aws_api_gateway_resource.costs.id
  http_method = aws_api_gateway_method.options_costs.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}
resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.cost_api.id
  resource_id = aws_api_gateway_resource.costs.id
  http_method = aws_api_gateway_method.options_costs.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.cost_api.id
  resource_id = aws_api_gateway_resource.costs.id
  http_method = aws_api_gateway_method.options_costs.http_method
  status_code = aws_api_gateway_method_response.options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}
