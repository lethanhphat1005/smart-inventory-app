output "parameter_arns" {
  description = "ARN của các SSM parameters"

  value = {
    for key, parameter in aws_ssm_parameter.main :
    key => parameter.arn
  }
}

output "parameter_names" {
  description = "Tên của các SSM parameters"

  value = {
    for key, parameter in aws_ssm_parameter.main :
    key => parameter.name
  }
}
