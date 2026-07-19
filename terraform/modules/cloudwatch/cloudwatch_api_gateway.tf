resource "aws_cloudwatch_dashboard" "api_gateway" {
  dashboard_name = "${var.project_name}-api-gateway-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type  = "metric",
        x     = 0, y = 0,
        width = 12, height = 6,
        properties = {
          title  = "API Gateway 4XX Errors",
          view   = "timeSeries",
          region = var.region,
          stat   = "Sum",
          metrics = [
            ["AWS/ApiGateway", "4XXError", "ApiId", var.apigw.api_id, "Stage", var.apigw.api_stage]
          ]
        }
      },
      {
        type  = "metric",
        x     = 12, y = 0,
        width = 12, height = 6,
        properties = {
          title  = "API Gateway 5XX Errors",
          view   = "timeSeries",
          region = var.region,
          stat   = "Sum",
          metrics = [
            ["AWS/ApiGateway", "5XXError", "ApiId", var.apigw.api_id, "Stage", var.apigw.api_stage]
          ]
        }
      },
      {
        type  = "metric",
        x     = 0, y = 6,
        width = 12, height = 6,
        properties = {
          title  = "API Gateway Latency (End-to-End)",
          view   = "timeSeries",
          region = var.region,
          stat   = "Average",
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiId", var.apigw.api_id, "Stage", var.apigw.api_stage]
          ]
        }
      },
      {
        type  = "metric",
        x     = 12, y = 6,
        width = 12, height = 6,
        properties = {
          title  = "API Gateway Integration Latency (Lambda Execution Time)",
          view   = "timeSeries",
          region = var.region,
          stat   = "Average",
          metrics = [
            ["AWS/ApiGateway", "IntegrationLatency", "ApiId", var.apigw.api_id, "Stage", var.apigw.api_stage]
          ]
        }
      },
      {
        type  = "metric",
        x     = 0, y = 12,
        width = 12, height = 6,
        properties = {
          title  = "API Gateway Request Count",
          view   = "timeSeries",
          region = var.region,
          stat   = "Sum",
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiId", var.apigw.api_id, "Stage", var.apigw.api_stage]
          ]
        }
      },
    ]
  })
}

# Theo dõi 4xx Errors
resource "aws_cloudwatch_metric_alarm" "apigw_4xx_errors" {
  alarm_name          = "${var.project_name}-apigw-4xx-errors"
  alarm_description   = "HTTP API 4XX error rate >= 5%"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0.05
  evaluation_periods  = 5

  alarm_actions = [aws_sns_topic.notifications.arn]

  metric_query {
    id = "m4xx"
    metric {
      namespace   = "AWS/ApiGateway"
      metric_name = "4xx"
      period      = 60
      stat        = "Sum"
      dimensions = {
        ApiId = var.apigw.api_id
        Stage = var.apigw.api_stage
      }
    }
    return_data = false
  }

  metric_query {
    id = "mcount"
    metric {
      namespace   = "AWS/ApiGateway"
      metric_name = "Count"
      period      = 60
      stat        = "Sum"
      dimensions = {
        ApiId = var.apigw.api_id
        Stage = var.apigw.api_stage
      }
    }
    return_data = false
  }

  metric_query {
    id          = "e1"
    label       = "4xx_rate"
    expression  = "m4xx / mcount"
    return_data = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-apigw-4xx-errors"
  })
}

# Theo dõi 5xx Errors
resource "aws_cloudwatch_metric_alarm" "apigw_5xx_errors" {
  alarm_name          = "${var.project_name}-apigw-5xx-errors"
  alarm_description   = "HTTP API 5XX error rate >= 5%"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0.05
  evaluation_periods  = 3

  alarm_actions = [aws_sns_topic.notifications.arn]
  ok_actions    = [aws_sns_topic.notifications.arn]

  metric_query {
    id = "m5xx"
    metric {
      namespace   = "AWS/ApiGateway"
      metric_name = "5xx"
      period      = 60
      stat        = "Sum"
      dimensions = {
        ApiId = var.apigw.api_id
        Stage = var.apigw.api_stage
      }
    }
    return_data = false
  }

  metric_query {
    id = "mcount"
    metric {
      namespace   = "AWS/ApiGateway"
      metric_name = "Count"
      period      = 60
      stat        = "Sum"
      dimensions = {
        ApiId = var.apigw.api_id
        Stage = var.apigw.api_stage
      }
    }
    return_data = false
  }

  metric_query {
    id          = "e2"
    expression  = "m5xx / mcount"
    label       = "5xx_rate"
    return_data = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-apigw-5xx-errors"
  })
}

# Theo dõi latency - 10% users đang phải chờ ≥ 2.5s
resource "aws_cloudwatch_metric_alarm" "apigw_high_latency" {
  alarm_name          = "${var.project_name}-apigw-high-latency"
  namespace           = "AWS/ApiGateway"
  metric_name         = "Latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 2500
  period              = 60
  evaluation_periods  = 5
  # INFO: extended_statistic hỗ trợ chỉ số p0.0 - p100
  extended_statistic = "p90" # 10% request chậm nhất

  alarm_actions = [aws_sns_topic.notifications.arn]
  ok_actions    = [aws_sns_topic.notifications.arn]

  dimensions = {
    ApiId = var.apigw.api_id
    Stage = var.apigw.api_stage
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-apigw-high-latency"
  })
}

# Theo dõi số traffic
resource "aws_cloudwatch_metric_alarm" "apigw_request_spike" {
  alarm_name          = "${var.project_name}-apigw-request-spike"
  namespace           = "AWS/ApiGateway"
  metric_name         = "Count"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 200
  period              = 60
  evaluation_periods  = 1
  statistic           = "Sum"

  alarm_actions = [aws_sns_topic.notifications.arn]
  ok_actions    = [aws_sns_topic.notifications.arn]

  dimensions = {
    ApiId = var.apigw.api_id
    Stage = var.apigw.api_stage
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-apigw-request-spike"
  })
}
