# Theo dõi số lượng event được gửi tới sqs
resource "aws_cloudwatch_metric_alarm" "notification_dlq_messages" {
  alarm_name        = "${var.project_name}-notification-dlq-messages"
  alarm_description = "Notification event was sent to the SQS DLQ"

  namespace   = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  period              = 300
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  statistic           = "Maximum"

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.notifications.arn]
  ok_actions    = [aws_sns_topic.notifications.arn]

  dimensions = {
    QueueName = var.notification_dlq_name
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-notification-dlq-messages"
  })
}
