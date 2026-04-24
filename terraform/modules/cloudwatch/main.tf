resource "aws_cloudwatch_log_group" "backend" {
  name              = "${var.log_group_prefix}/${var.project_name}/backend"
  retention_in_days = var.log_retention_in_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-backend-log-group"
  })
}

resource "aws_cloudwatch_log_group" "nginx" {
  count = var.enable_nginx_log_group ? 1 : 0

  name              = "${var.log_group_prefix}/${var.project_name}/nginx"
  retention_in_days = var.log_retention_in_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-nginx-log-group"
  })
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = concat(
      [
        {
          type   = "metric"
          x      = 0
          y      = 0
          width  = 12
          height = 6

          properties = {
            title   = "EC2 CPU Utilization"
            view    = "timeSeries"
            stacked = false
            region  = var.region
            stat    = "Average"
            period  = 300

            metrics = [
              ["AWS/EC2", "CPUUtilization", "InstanceId", var.instance_id]
            ]
          }
        },
        {
          type   = "metric"
          x      = 12
          y      = 0
          width  = 12
          height = 6

          properties = {
            title   = "EC2 Network"
            view    = "timeSeries"
            stacked = false
            region  = var.region
            stat    = "Average"
            period  = 300

            # Lượng data vào/ra của instance
            metrics = [
              ["AWS/EC2", "NetworkIn", "InstanceId", var.instance_id],
              [".", "NetworkOut", ".", "."]
            ]
          }
        },
        {
          type   = "metric"
          x      = 0
          y      = 6
          width  = 12
          height = 6

          properties = {
            title   = "EC2 Status Checks"
            view    = "timeSeries"
            stacked = false
            region  = var.region
            stat    = "Maximum"
            period  = 60

            metrics = [
              ["AWS/EC2", "StatusCheckFailed", "InstanceId", var.instance_id],
              [".", "StatusCheckFailed_Instance", ".", "."],
              [".", "StatusCheckFailed_System", ".", "."]
            ]
          }
        },
      ],
      var.enable_disk_widget ? [
        {
          type   = "metric"
          x      = 12
          y      = 6
          width  = 12
          height = 6

          properties = {
            title   = "Disk Used Percent"
            view    = "timeSeries"
            stacked = false
            region  = var.region
            stat    = "Average"
            period  = 300

            metrics = [
              [
                "CWAgent",
                "disk_used_percent",
                "InstanceId",
                var.instance_id,
                "path",
                "/",
                "fstype",
                "xfs"
              ]
            ]
          }
        }
      ] : []
    )
  })
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-ec2-cpu-high"
  alarm_description   = "Alarm EC2 exceed CPU threshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cpu_alarm.threshold
  statistic           = "Average"
  period              = var.cpu_alarm.period
  evaluation_periods  = var.cpu_alarm.evaluation_periods
  treat_missing_data  = "missing" # INSUFFICIENT_DATA khi có các missing data point

  alarm_actions = [aws_sns_topic.notifications.arn]

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2-cpu-high"
  })
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  alarm_name          = "${var.project_name}-ec2-status-check-failed"
  alarm_description   = "Alarm EC2 status check fail"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 1
  treat_missing_data  = "missing"

  alarm_actions = [aws_sns_topic.notifications.arn]

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2-status-check-failed"
  })
}

resource "aws_cloudwatch_metric_alarm" "attached_ebs_failed" {
  count = var.enable_attached_ebs_alarm ? 1 : 0

  alarm_name          = "${var.project_name}-ec2-attached-ebs-failed"
  alarm_description   = "Alarm EC2 EBS status check fail."
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed_AttachedEBS"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 1
  treat_missing_data  = "missing"

  alarm_actions = [aws_sns_topic.notifications.arn]

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2-attached-ebs-failed"
  })
}

resource "aws_cloudwatch_metric_alarm" "disk_used_high" {
  count = var.enable_disk_alarm ? 1 : 0

  alarm_name          = "${var.project_name}-ec2-disk-used-high"
  alarm_description   = "Alarm EC2 high disk usage"
  namespace           = "CWAgent"
  metric_name         = "disk_used_percent"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.disk_alarm.threshold
  statistic           = "Average"
  period              = var.disk_alarm.period
  evaluation_periods  = var.disk_alarm.evaluation_periods
  treat_missing_data  = "missing"

  alarm_actions = [aws_sns_topic.notifications.arn]

  dimensions = {
    InstanceId = var.instance_id
    path       = "/"
    fstype     = "xfs"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2-disk-used-high"
  })
}