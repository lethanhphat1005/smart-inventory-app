variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name, prefix cho các tài nguyên"
  type        = string
  default     = "storix-production"
}

variable "tags" {
  description = "Tag cho toàn bộ resource"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "storix"
  }
}

variable "image_tag" {
  description = "Image tag cho lamba function"
  type        = string
  default     = "latest"
}

variable "sns_email" {
  description = "Email để nhận cảnh báo từ cloudwatch"
  type        = string
}

variable "lambda_api_env" {
  description = "Biến môi trường của lambda API function"
  type        = map(any)
  sensitive   = true
}

variable "lambda_noti_env" {
  description = "Biến môi trường của lambda Noti function"
  type        = map(any)
  sensitive   = true
}

variable "secret_parameters" {
  description = "Các secret lưu trong SSM Parameter"
  type        = map(any)
  sensitive   = true
}
