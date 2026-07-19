variable "project_name" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "tags" {
  type = map(string)
}

variable "sns_email" {
  description = "Email để SNS gửi cảnh báo khi alarm kích hoạt"
  type        = string
}

variable "lambda_function_names" {
  description = "Tên lamba function"
  type = object({
    api_function  = string
    cron_function = string
  })
}

variable "apigw" {
  type = object({
    api_name  = string
    api_id    = string
    api_stage = string
  })
}

variable "log_retention_in_days" {
  description = "Số ngày lưu log trong CloudWatch Logs"
  type        = number
  default     = 14
}
