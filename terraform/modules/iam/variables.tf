variable "project_name" {
  description = "Ten project de dat ten resource IAM."
  type        = string
}

variable "tags" {
  description = "Tag chung cho resource."
  type        = map(string)
  default     = {}
}

variable "enable_cloudwatch_agent_policy" {
  description = "Gán AWS managed policy CloudWatchAgentServerPolicy."
  type        = bool
  default     = true
}