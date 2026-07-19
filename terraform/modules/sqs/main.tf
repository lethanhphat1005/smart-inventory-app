# SQS Queue dùng để đẩy các dead-letter message của Event Bridge và trigger alarm
# cảnh báo rằng cron notification không thành công
resource "aws_sqs_queue" "notification_dlq" {
  name = "${var.project_name}-notification-dlq"

  # Thời gian SQS giữ lại tin nhắn
  message_retention_seconds = 604800 # 7 ngày

  # Mã hóa bằng SQS-managed key, không phát sinh KMS key riêng
  sqs_managed_sse_enabled = true

  tags = merge(var.tags, {
    QueueName = "${var.project_name}-notification-dlq"
  })
}
