variable "project_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "expired_days" {
  description = "Number of days untagged image stored"
  type        = number
  default     = 7
}

variable "max_image_count" {
  description = "Number of image tag th repository could store"
  type        = number
  default     = 5
}
