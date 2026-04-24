# Gửi mail khi có cảnh báo
resource "aws_sns_topic" "notifications" {
  name = "${var.project_name}-cloudwatch-notify"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = var.sns_email
}