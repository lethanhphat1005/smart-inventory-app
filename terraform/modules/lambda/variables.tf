variable "project_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

# variable "vpc_subnet_ids" {
#   description = "List of VPC subnet IDs for Lambda functions"
#   type        = list(string)
#   default     = []
# }

# variable "vpc_security_group_ids" {
#   description = "List of VPC security group IDs for Lambda functions"
#   type        = list(string)
#   default     = []
# }

variable "function_name_suffix" {
  description = "Name suffix of function for creating many functions"
  type        = string
  default     = "1"
}

variable "lambda_role_arn" {
  description = "IAM role of lambda function"
  type        = string
}

variable "lambda_function_config" {
  description = "Config of lambda function"
  type = object({
    image_uri     = string
    memory        = number
    timeout       = number
    architectures = list(string)
    environment   = map(any)
  })
}

variable "image_command" {
  description = "Command to override CMD in Dockerfile when creating function"
  type        = list(string)
}

variable "reserved_concurrent_executions" {
  description = "Specifies the maximum number of invocations allowed for functions to run concurrently"
  type        = number
  default     = -1
}

variable "async_invoke_config" {
  description = "Cấu hình retry và failure destination cho asynchronous invocation"

  type = object({
    maximum_event_age_in_seconds = number
    maximum_retry_attempts       = number
    on_failure_destination_arn   = string
  })

  default = null
}
