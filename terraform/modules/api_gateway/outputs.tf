output "api_name" {
  description = "Tên of API Gateway HTTP API"
  value       = aws_apigatewayv2_api.lambda_http.name
}

output "api_id" {
  description = "ID of API Gateway HTTP API"
  value       = aws_apigatewayv2_api.lambda_http.id
}

output "api_endpoint" {
  description = "Basic endpoint of API Gateway (no stage)"
  value       = aws_apigatewayv2_api.lambda_http.api_endpoint
}

output "stage_name" {
  description = "Stage name of API Gateway"
  value       = aws_apigatewayv2_stage.lambda_stage.name
}

output "stage_arn" {
  description = "Stage ARN API Gateway"
  value       = aws_apigatewayv2_stage.lambda_stage.arn
}