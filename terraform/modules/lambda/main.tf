resource "aws_lambda_function" "main" {
  function_name = "${var.project_name}-lambda-function-${var.function_name_suffix}"

  role         = var.lambda_role_arn
  package_type = "Image"
  image_uri    = var.lambda_function_config.image_uri

  memory_size = var.lambda_function_config.memory
  timeout     = var.lambda_function_config.timeout

  architectures = var.lambda_function_config.architectures

  reserved_concurrent_executions = var.reserved_concurrent_executions

  # # Bật X-ray tracing
  # tracing_config {
  #   mode = "Active"
  # }

  image_config {
    command = var.image_command
  }

  # Biến môi trường
  environment {
    variables = var.lambda_function_config.environment
  }

  tags = merge(var.tags, {
    FunctionName = "${var.project_name}-lambda-function"
  })
}
