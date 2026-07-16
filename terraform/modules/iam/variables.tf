variable "project_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "lambda_scheduler_function_arn" {
  description = "ARN of the Lambda function invoked by the scheduler"
  type        = string
}

variable "sqs_dlq_arn" {
  description = "ARN of the SQS queue to recieve dead-letter messages from Event Bridge"
  type        = string
}
