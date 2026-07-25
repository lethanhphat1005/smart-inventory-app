output "api_lambda_role_arn" {
  description = "Execution role ARN của API Lambda"
  value       = aws_iam_role.lambda_api.arn
}

output "cron_lambda_role_arn" {
  description = "Execution role ARN của Notification Lambda"
  value       = aws_iam_role.lambda_cron.arn
}

output "scheduler_role_arn" {
  description = "Execution role ARN của EventBridge Scheduler"
  value       = aws_iam_role.scheduler.arn
}
