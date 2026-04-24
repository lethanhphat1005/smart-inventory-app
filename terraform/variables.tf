variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name, prefix cho các tài nguyên"
  type        = string
  default     = "storix-backend"
}

variable "tags" {
  description = "Tag cho toàn bộ resource"
  type        = map(string)
  default = {
    Environment = "prod"
    Project     = "storix"
  }
}

variable "vpc_cidr" {
  description = "CIDR block cho VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "allowed_ssh_cidrs" {
  description = "Danh sách IP được phép SSH vào EC2"
  type        = list(string)
}

variable "public_key_path" {
  description = "Public key để SSH vào EC2"
  type        = string
}

variable "sns_email" {
  description = "Email để nhận cảnh báo từ cloudwatch"
  type        = string
}

variable "hosted_zone_id" {
  type    = string
  default = null
}