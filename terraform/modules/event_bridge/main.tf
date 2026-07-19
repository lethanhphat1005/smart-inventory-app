resource "aws_scheduler_schedule" "main" {
  name = "${var.project_name}-schedule-${var.name_suffix}"

  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_expression_timezone
  state                        = var.enabled ? "ENABLED" : "DISABLED"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = var.target_arn
    role_arn = var.role_arn
    input    = var.input

    retry_policy {
      maximum_event_age_in_seconds = var.maximum_event_age_in_seconds
      maximum_retry_attempts       = var.maximum_retry_attempts
    }

    # Chỉ định SQS queue để các fail event được gửi vào để xử lý
    dead_letter_config {
      arn = var.dead_letter_arn
    }
  }
}
