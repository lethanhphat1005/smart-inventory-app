variable "project_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "domain_name" {
  type        = string
  description = "Domain chính (example.com)"
}

variable "subdomain" {
  type        = string
  description = "Subdomain (api.example.com)"
}

variable "ec2_public_ip" {
  type        = string
  description = "Elastic IP của EC2"
}

variable "hosted_zone_id" {
  type        = string
  description = "Hosted zone có sẵn"
  default     = null
}

variable "create_hosted_zone" {
  type    = bool
  default = false
}

variable "create_root_record" {
  type    = bool
  default = false
}

variable "ttl" {
  type    = number
  default = 300
}