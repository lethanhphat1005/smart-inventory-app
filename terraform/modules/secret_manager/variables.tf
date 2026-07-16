variable "project_name" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

# variable "supabase_services" {
#   description = "Secret for supabase connection string"
#   type = map(object({
#     database_url = string
#   }))
# }

variable "auth_service" {
  type = object({
    mongo_username       = string
    mongo_password       = string
    mongo_host           = string
    private_key          = string
    refresh_token_secret = string
  })
  sensitive = true
}

variable "public_key" {
  type      = string
  sensitive = true
}
