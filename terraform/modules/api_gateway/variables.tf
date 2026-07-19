variable "project_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "api_routes" {
  description = "Corresponding routes for Lambda functions"
  type = object({
    lambda_invoke_arn = string
    lambda_arn        = string
  })
}
