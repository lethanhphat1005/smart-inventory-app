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
    FunctionName = "${var.project_name}-lambda-function-${var.function_name_suffix}"
  })
}

# Xử lý lỗi khi lambda invoke bất đồng bộ
# Hiện chỉ dành cho cron_function
resource "aws_lambda_function_event_invoke_config" "notification" {
  count = var.async_invoke_config == null ? 0 : 1

  function_name = aws_lambda_function.main.function_name

  maximum_event_age_in_seconds = var.async_invoke_config.maximum_event_age_in_seconds
  maximum_retry_attempts       = var.async_invoke_config.maximum_retry_attempts

  # Gửi failue events tới đích được chỉ định
  destination_config {
    on_failure {
      destination = var.async_invoke_config.on_failure_destination_arn
    }
  }
}
