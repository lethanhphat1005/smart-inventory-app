variable "project_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "api_routes" {
  description = "Corresponding routes for Lambda functions"
  type = object({
    lambda_invoke_arn = string
    lambda_arn        = string
  })
}

variable "throttling_rate_limit" {
  description = "Số request trung bình mỗi giây"
  type        = number
  default     = 10
}

variable "throttling_burst_limit" {
  description = "Số request tối đa cho phép trong một khoảng rất ngắn"
  type        = number
  default     = 20
}
