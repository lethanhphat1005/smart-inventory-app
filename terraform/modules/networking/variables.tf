variable "project_name" {
  description = "Tên project để đặt tên resource"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "tags" {
  description = "Tag chung cho toàn bộ resource"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block cho VPC"
  type        = string
}

variable "public_subnets" {
  description = "Danh sách CIDR cho public subnets"
  type        = list(string)
}

variable "allowed_ssh_cidrs" {
  description = "Danh sách CIDR được phép SSH vào EC2"
  type        = list(string)
  default     = []
}

variable "enable_eip" {
  description = "Có tạo Elastic IP cho EC2 hay không"
  type        = bool
  default     = true
}