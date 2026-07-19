variable "project_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "name_suffix" {
  description = "Suffix used for distinguishing EventBridge Scheduler resources"
  type        = string
}

variable "target_arn" {
  description = "Lamba function which call event bridge"
  type        = string
}

variable "role_arn" {
  description = "IAM role to invoke lambda function"
  type        = string
}

variable "schedule_expression" {
  description = "EventBridge Scheduler cron or rate expression"
  type        = string
}

variable "schedule_expression_timezone" {
  description = "Timezone used to evaluate the schedule expression"
  type        = string
  default     = "Asia/Ho_Chi_Minh"
}

variable "input" {
  description = "JSON payload sent to the Lambda function"
  type        = string
  default     = "{}"

  validation {
    condition     = can(jsondecode(var.input))
    error_message = "input must be a valid JSON string."
  }
}

variable "enabled" {
  description = "Whether the schedule is enabled"
  type        = bool
  default     = true
}

variable "maximum_retry_attempts" {
  description = "Maximum number of retry attempts"
  type        = number
  default     = 2
}

variable "maximum_event_age_in_seconds" {
  description = "Maximum age of an event before EventBridge Scheduler discards it"
  type        = number
  default     = 3600
}

variable "dead_letter_arn" {
  description = "ARN of queue which recieve dead-letter message for alarm"
  type        = string
}
