output "lambda_role_name" {
  description = "Lambda IAM role name"
  value       = aws_iam_role.lambda.name
}

output "lambda_role_arn" {
  description = "Lambda IAM role ARN"
  value       = aws_iam_role.lambda.arn
}

output "scheduler_role_arn" {
  description = "EventBridge IAM role ARN"
  value       = aws_iam_role.scheduler.arn
}
