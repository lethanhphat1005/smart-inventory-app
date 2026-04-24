output "dashboard_name" {
  description = "Tên CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "backend_log_group_name" {
  description = "Tên log group backend."
  value       = aws_cloudwatch_log_group.backend.name
}

output "backend_log_group_arn" {
  description = "ARN log group backend."
  value       = aws_cloudwatch_log_group.backend.arn
}

output "nginx_log_group_name" {
  description = "Tên log group nginx."
  value       = var.enable_nginx_log_group ? aws_cloudwatch_log_group.nginx[0].name : null
}

output "cpu_alarm_name" {
  description = "Tên alarm CPU."
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}

output "status_check_alarm_name" {
  description = "Tên alarm status check."
  value       = aws_cloudwatch_metric_alarm.status_check_failed.alarm_name
}

output "disk_alarm_name" {
  description = "Tên alarm disk."
  value       = var.enable_disk_alarm ? aws_cloudwatch_metric_alarm.disk_used_high[0].alarm_name : null
}