output "s3_backup_bucket" {
  description = "Thông tin bucket backup"

  value = {
    bucket_arn  = module.s3_backup.bucket_arn
    bucket_name = module.s3_backup.bucket_name
  }
}

output "ecr_repository_urls" {
  description = "ECR repository URL của backend"
  value       = module.ecr.repository_urls
}

output "iam" {
  description = "Thông tin IAM role"

  value = {
    lambda_role_arn = {
      api_function  = module.iam.api_lambda_role_arn
      cron_function = module.iam.cron_lambda_role_arn
    }
    scheduler_role_arn = module.iam.scheduler_role_arn
  }
}

output "api_lambda" {
  description = "Thông tin API Lambda"

  value = {
    function_name = module.lambda_api.function_name
    function_arn  = module.lambda_api.function_arn
    invoke_arn    = module.lambda_api.function_invoke_arn
  }
}

output "notification_lambda" {
  description = "Thông tin Notification Lambda"

  value = {
    function_name = module.lambda_cron.function_name
    function_arn  = module.lambda_cron.function_arn
    invoke_arn    = module.lambda_cron.function_invoke_arn
  }
}

output "api_gateway" {
  description = "Thông tin API Gateway"

  value = {
    api_name   = module.apigw.api_name
    api_id     = module.apigw.api_id
    stage_name = module.apigw.stage_name
  }
}

output "api_base_url" {
  description = "Base URL của HTTP API Gateway"

  value = (
    module.apigw.stage_name == "$default"
    ? "https://${module.apigw.api_id}.execute-api.${var.region}.amazonaws.com"
    : "https://${module.apigw.api_id}.execute-api.${var.region}.amazonaws.com/${module.apigw.stage_name}"
  )
}

output "notification_dlq" {
  description = "Thông tin SQS DLQ của notification scheduler"

  value = {
    queue_arn = module.sqs_dlq.queue_arn
  }
}

output "ssm_parameters" {
  description = "ARN và name của SSM parameters; không chứa giá trị secret"
  value = {
    parameter_arns  = module.ssm_parameters.parameter_arns
    parameter_names = module.ssm_parameters.parameter_names
  }
}

output "scheduler_role_arn" {
  description = "IAM role ARN được EventBridge Scheduler sử dụng"
  value       = module.iam.scheduler_role_arn
}

output "firebase_parameter_arn" {
  description = "ARN only của fire base service account key parameter"
  value       = module.ssm_parameters.parameter_arns["firebase_service_account"]
}
