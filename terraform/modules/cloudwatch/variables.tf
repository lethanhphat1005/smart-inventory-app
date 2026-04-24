variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_id" {
  description = "EC2 instance ID"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "sns_email" {
  description = "Email để SNS gửi cảnh báo khi alarm kích hoạt"
  type        = string
}

variable "log_group_prefix" {
  description = "Prefix cho CloudWatch log group"
  type        = string
  default     = "/sis"
}

variable "log_retention_in_days" {
  description = "Số ngày lưu log trong CloudWatch Logs"
  type        = number
  default     = 14
}

variable "enable_nginx_log_group" {
  description = "Có tạo log group riêng cho nginx không"
  type        = bool
  default     = true
}

variable "cpu_alarm" {
  description = "Cấu hình metric để kích hoạt CPU alarm"
  type = object({
    threshold          = number
    period             = number
    evaluation_periods = number
  })
  default = {
    threshold          = 80
    period             = 300
    evaluation_periods = 2
  }
}

variable "enable_attached_ebs_alarm" {
  description = "Có bật alarm cho attached EBS status check không"
  type        = bool
  default     = true
}

variable "enable_disk_widget" {
  description = "Có hiển thị widget disk trên dashboard không (cần CloudWatch Agent)"
  type        = bool
  default     = false
}

variable "enable_disk_alarm" {
  description = "Có bật alarm disk_used_percent không (cần CloudWatch Agent)"
  type        = bool
  default     = false
}

variable "disk_alarm" {
  description = "Cấu hình metric để kích hoạt disk alarm"
  type = object({
    threshold          = number
    period             = number
    evaluation_periods = number
  })
  default = {
    threshold          = 85
    period             = 300
    evaluation_periods = 1
  }
}