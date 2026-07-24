output "queue_arn" {
  description = "ARN of SQS queue"
  value       = aws_sqs_queue.notification_dlq.arn
}

output "queue_name" {
  description = "Name of SQS queue"
  value       = aws_sqs_queue.notification_dlq.name
}
