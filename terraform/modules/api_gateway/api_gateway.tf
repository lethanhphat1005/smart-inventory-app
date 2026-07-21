resource "aws_apigatewayv2_api" "lambda_http" {
  name          = "${var.project_name}-serverless-lambda-gw"
  protocol_type = "HTTP"

  tags = merge(var.tags, {
    Name = "${var.project_name}-serverless-lambda-gw"
  })
}

resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id      = aws_apigatewayv2_api.lambda_http.id
  name        = "$default"
  auto_deploy = true

  # Rate limit áp dụng mặc định cho tất cả route trong stage
  default_route_settings {
    throttling_rate_limit  = var.throttling_rate_limit
    throttling_burst_limit = var.throttling_burst_limit
    detailed_metrics_enabled = true # bật metric chi tiết theo route (optional)
  }
}

resource "aws_apigatewayv2_integration" "lambda_functions" {
  integration_type       = "AWS_PROXY"
  api_id                 = aws_apigatewayv2_api.lambda_http.id
  integration_uri        = var.api_routes.lambda_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lambda_routes" {
  api_id    = aws_apigatewayv2_api.lambda_http.id
  route_key = "$default"

  target = "integrations/${aws_apigatewayv2_integration.lambda_functions.id}"
}

# Permission cho phép API Gateway invoke tới lambda function
resource "aws_lambda_permission" "allow_api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.api_routes.lambda_arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda_http.execution_arn}/*"
}
