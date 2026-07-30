resource "aws_iam_role" "scheduler" {
  name = "${var.project_name}-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "SchedulerAssumeRole"
        Effect = "Allow"
        Action = "sts:AssumeRole"

        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-scheduler-role"
  })
}

resource "aws_iam_role_policy" "scheduler" {
  name = "${var.project_name}-scheduler-policy"
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "InvokeNotificationLambda"
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = var.lambda_scheduler_function_arn
      },
      {
        Sid      = "SendSchedulerFailureToDLQ"
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = var.sqs_dlq_arn
      }
    ]
  })
}
