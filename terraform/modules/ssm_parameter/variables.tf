variable "project_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "parameter_name_prefix" {
  description = "Prefix chung trong parameter name"
  type        = string
  default     = "/storix"
}

variable "parameters_config" {
  description = "Config các parameter cần tạo"
  type = map(object({
    name  = string
    value = string
  }))
  sensitive = true
}

