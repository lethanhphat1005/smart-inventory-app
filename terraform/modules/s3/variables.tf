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

variable "enable_current_lifecycle" {
  type    = bool
  default = true
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
    deep_archive = 120
    expiration   = 365
  }
}

# variable "enable_noncurrent_lifecycle" {
#   type    = bool
#   default = false
# }

# variable "noncurrent_version_transition_day" {
#   description = "Số ngày chuyển lưu trữ storage class của old version"

#   type = object({
#     glacier_ir   = number
#     deep_archive = number
#     expiration   = number
#   })
#   default = {
#     glacier_ir   = 30
#     deep_archive = 120
#     expiration   = 365
#   }
# }
