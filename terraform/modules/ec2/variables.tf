variable "project_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "iam_instance_profile_name" {
  description = "Tên IAM instance profile gắn vào EC2."
  type        = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "create_key_pair" {
  type    = bool
  default = true
}

variable "key_pair_name" {
  type = string
}

variable "public_key" {
  type     = string
  default  = null
  nullable = true
}

variable "has_associate_public_ip" {
  type    = bool
  default = true
}

variable "has_disable_api_termination" {
  type    = bool
  default = false
}

variable "root_volume_size" {
  type    = number
  default = 20
}

variable "root_volume_type" {
  type    = string
  default = "gp3"
}

variable "enable_eip_association" {
  description = "Có gán EIP cho instance hay không"
  type        = bool
  default     = true
}

variable "eip_allocation_id" {
  type     = string
  default  = null
  nullable = true
}