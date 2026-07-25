variable "project_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "ssm_parameter_arns" {
  description = "ARN of the SSM Parameter which store secrets for lambda function"
  type        = list(string)
  default     = []
}

variable "function_ssm_parameter_arns" {
  description = "SSM parameter ARNs mà mỗi lambda function được phép đọc"
  type = object({
    api_function  = list(string)
    cron_function = list(string)
  })
}

variable "lambda_scheduler_function_arn" {
  description = "ARN of the Lambda function invoked by the scheduler"
  type        = string
}

variable "sqs_dlq_arn" {
  description = "ARN of the SQS queue to recieve dead-letter messages from Event Bridge"
  type        = string
}
