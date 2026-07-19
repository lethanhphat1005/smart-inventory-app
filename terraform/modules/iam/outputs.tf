output "lambda_role_arn" {
  description = "Lambda IAM role ARN"
  value       = aws_iam_role.lambda.arn
}

# output "lambda_role_arns" {
#   description = "IAM role ARN của từng Lambda"

#   value = {
#     for key, role in aws_iam_role.lambda :
#     key => role.arn
#   }
# }

output "scheduler_role_arn" {
  description = "EventBridge IAM role ARN"
  value       = aws_iam_role.scheduler.arn
}
