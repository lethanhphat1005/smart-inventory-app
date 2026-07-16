output "queue_arn" {
  description = "ARN of SQS queue"
  value       = aws_sqs_queue.notification_dlq.arn
}
