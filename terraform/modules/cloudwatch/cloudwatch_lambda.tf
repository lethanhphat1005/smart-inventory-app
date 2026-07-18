resource "aws_cloudwatch_dashboard" "lambda" {
  dashboard_name = "${var.project_name}-lambda-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type  = "metric",
        x     = 0, y = 0,
        width = 24, height = 6,
        properties = {
          title   = "Lambda Errors",
          view    = "timeSeries",
          stacked = false, # Biểu thị đường xếp chồng (true) hoặc đường riêng biệt (false)
          region  = var.region,
          stat    = "Sum",
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_names.api_function],
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_names.cron_function],
          ]
        }
      },
      {
        type  = "metric",
        x     = 0, y = 6,
        width = 24, height = 6,
        properties = {
          title  = "Lambda Duration p95",
          view   = "timeSeries",
          region = var.region,
          stat   = "p95",
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", var.lambda_function_names.api_function],
            ["AWS/Lambda", "Duration", "FunctionName", var.lambda_function_names.cron_function],
          ]
        }
      },
      {
        type  = "metric",
        x     = 0, y = 12,
        width = 24, height = 6,
        properties = {
          title  = "Lambda Throttles",
          view   = "timeSeries",
          region = var.region,
          stat   = "Sum",
          metrics = [
            ["AWS/Lambda", "Throttles", "FunctionName", var.lambda_function_names.api_function],
            ["AWS/Lambda", "Throttles", "FunctionName", var.lambda_function_names.cron_function],
          ]
        }
      },
      {
        type  = "metric",
        x     = 0, y = 18,
        width = 24, height = 6,
        properties = {
          title  = "Concurrent Executions",
          view   = "timeSeries",
          region = var.region,
          stat   = "Maximum",
          metrics = [
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", var.lambda_function_names.api_function],
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", var.lambda_function_names.cron_function],
          ]
        }
      },
      {
        type  = "metric",
        x     = 0, y = 24,
        width = 24, height = 6,
        properties = {
          title  = "Lambda Invocations",
          view   = "timeSeries",
          region = var.region,
          stat   = "Sum",
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.lambda_function_names.api_function],
            ["AWS/Lambda", "Invocations", "FunctionName", var.lambda_function_names.cron_function],
          ]
        }
      }
    ]
  })
}

# Theo dõi Log
resource "aws_cloudwatch_log_group" "lambda" {
  for_each = var.lambda_function_names

  name              = "/aws/lambda/${each.value}" # Chỉ định nơi lưu trữ log
  retention_in_days = var.log_retention_in_days    # Lưu trữ log trong X ngày

  tags = merge(var.tags, {
    Name = "${var.project_name}-lambda-${each.key}-log"
  })
}

# Theo dõi Error - Có tổng số lỗi >= 1 trong 60s
# Cho lambda api function và noti function
resource "aws_cloudwatch_metric_alarm" "lambda_error" {
  for_each = var.lambda_function_names

  alarm_name          = "${var.project_name}-lambda-${each.key}-error"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0 # Ngưỡng kích hoạt alarm
  # INFO: CloudWatch theo dõi metric theo datapoint (ô thời gian), độ dài mỗi datapoint quy định bằng period
  # INFO: Sau X datapoint (quy định bằng evaluation_periods), CloudWatch gom các metric với nhau và so sánh
  # INFO: datapoints_to_alarm: Số datapoint trong X datapoint (evaluation_periods) phải vượt threshold để kích hoạt alarm
  # INFO: Ví dụ: evaluation_periods  = 5 & datapoints_to_alarm = 3 -> Cần 3/5 datapoint bị lỗi để kích hoạt alarm
  period              = 60 # Độ dài mỗi datapoint (sec)
  evaluation_periods  = 3  # Số datapoint cloudwatch so sánh để xem xét vượt ngưỡng
  datapoints_to_alarm = 3
  statistic           = "Sum"

  # Hành động thực hiện khi alarm kích hoạt
  alarm_actions = [aws_sns_topic.notifications.arn]
  ok_actions    = [aws_sns_topic.notifications.arn]

  # Filter theo giá trị
  dimensions = {
    FunctionName = each.value
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-lambda-${each.key}-error"
    Function = each.key
  })
}

# Theo dõi Duration - Duration p95 >= 80% timeout
resource "aws_cloudwatch_metric_alarm" "lambda_api_duration" {
  alarm_name          = "${var.project_name}-lambda-api-function-duration"
  namespace           = "AWS/Lambda"
  metric_name         = "Duration"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 8000
  period              = 60
  evaluation_periods  = 15
  datapoints_to_alarm = 15
  extended_statistic  = "p95" # percentile

  alarm_actions = [aws_sns_topic.notifications.arn]
  ok_actions    = [aws_sns_topic.notifications.arn]

  dimensions = {
    FunctionName = var.lambda_function_names.api_function
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-lambda-api-function-duration"
    Function = var.lambda_function_names.api_function
  })
}

# Theo dõi Duration - Duration Maximum >= 80% timeout
resource "aws_cloudwatch_metric_alarm" "lambda_cron_duration" {
  alarm_name          = "${var.project_name}-lambda-noti-function-duration"
  namespace           = "AWS/Lambda"
  metric_name         = "Duration"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 100000
  period              = 300
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  statistic           = "Maximum"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.notifications.arn]
  ok_actions    = [aws_sns_topic.notifications.arn]



  dimensions = {
    FunctionName = var.lambda_function_names.cron_function
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-lambda-noti-function-duration"
    Function = var.lambda_function_names.cron_function
  })
}

# Theo dõi Throttles (Lambda bị giới hạn tài nguyên, request) - Throttles > 0
resource "aws_cloudwatch_metric_alarm" "lambda_api_throttle" {
  alarm_name          = "${var.project_name}-lambda-api-function-throttle"
  namespace           = "AWS/Lambda"
  metric_name         = "Throttles"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  period              = 60
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  statistic           = "Sum"

  alarm_actions = [aws_sns_topic.notifications.arn]
  ok_actions    = [aws_sns_topic.notifications.arn]

  dimensions = {
    FunctionName = var.lambda_function_names.api_function
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-lambda-api-function-throttle"
    Function = var.lambda_function_names.api_function
  })
}

# Theo dõi Concurrent Evocation (Số instance lambda chạy đồng thời)
resource "aws_cloudwatch_metric_alarm" "lambda_api_high_concurrency" {
  alarm_name          = "${var.project_name}-lambda-high-api-function-concurrency"
  namespace           = "AWS/Lambda"
  metric_name         = "ConcurrentExecutions"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 50
  period              = 60
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  statistic           = "Maximum"

  alarm_actions = [aws_sns_topic.notifications.arn]
  ok_actions    = [aws_sns_topic.notifications.arn]

  dimensions = {
    FunctionName = var.lambda_function_names.api_function
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-lambda-api-function-high-concurrency"
    Function = var.lambda_function_names.api_function
  })
}

# Theo dõi Invocations (Tổng số lần gọi hàm lambda)
resource "aws_cloudwatch_metric_alarm" "lambda_api_invocation_spike" {
  alarm_name          = "${var.project_name}-lambda-api-function-invocation-spike"
  namespace           = "AWS/Lambda"
  metric_name         = "Invocations"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 200
  period              = 60
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  statistic           = "Sum"

  alarm_actions = [aws_sns_topic.notifications.arn]
  ok_actions    = [aws_sns_topic.notifications.arn]

  dimensions = {
    FunctionName = var.lambda_function_names.api_function
  }

  tags = merge(var.tags, {
    Name     = "${var.project_name}-lambda-api-function-invocation-spike"
    Function = var.lambda_function_names.api_function
  })
}
