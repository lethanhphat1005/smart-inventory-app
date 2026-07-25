data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid     = "LambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# API Lambda role
resource "aws_iam_role" "lambda_api" {
  name               = "${var.project_name}-api-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.project_name}-api-lambda-role"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_api_basic_execution" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_api_get_ssm_parameters" {
  name = "${var.project_name}-api-read-ssm-parameters"
  role = aws_iam_role.lambda_api.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadApiSSMParameters"
        Effect = "Allow"

        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]

        Resource = var.function_ssm_parameter_arns.api_function
      }
    ]
  })
}

# Notification Lambda role
resource "aws_iam_role" "lambda_cron" {
  name               = "${var.project_name}-notification-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.project_name}-notification-lambda-role"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_cron_basic_execution" {
  role       = aws_iam_role.lambda_cron.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_cron_get_ssm_parameters" {
  name = "${var.project_name}-notification-read-ssm-parameters"
  role = aws_iam_role.lambda_cron.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadNotificationSSMParameters"
        Effect = "Allow"

        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]

        Resource = var.function_ssm_parameter_arns.cron_function
      }
    ]
  })
}

# Chỉ Notification Lambda cần quyền gửi failed async invocation vào DLQ.
resource "aws_iam_role_policy" "lambda_cron_send_to_dlq" {
  name = "${var.project_name}-notification-send-to-dlq"
  role = aws_iam_role.lambda_cron.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "SendFailedAsyncInvocationToDLQ"
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = var.sqs_dlq_arn
      }
    ]
  })
}

# EventBridge Scheduler role
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
