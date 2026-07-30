variable "project_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "name" {
  type    = string
  default = ""
}

variable "enable_lifecycle" {
  description = "Có bật rule lifecycle không"

  type = object({
    old_version_lifecycle     = bool
    current_version_lifecycle = bool
  })
  default = {
    old_version_lifecycle     = false
    current_version_lifecycle = true
  }
}

variable "noncurrent_version_transition_day" {
  description = "Số ngày chuyển lưu trữ storage class của old version"

  type = object({
    glacier_ir   = number
    deep_archive = number
    expiration   = number
  })
  default = {
    glacier_ir   = 30
    deep_archive = 90
    expiration   = 365
  }
}

variable "current_version_transition_day" {
  description = "Số ngày chuyển lưu trữ storage class của current version"

  type = object({
    glacier_ir   = number
    deep_archive = number
    expiration   = number
  })
  default = {
    glacier_ir   = 30
    deep_archive = 90
    expiration   = 365
  }
}
