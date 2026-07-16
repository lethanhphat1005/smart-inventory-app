# NOTE: Tạo ECR và push image trước khi tạo lambda function và các resource liên quan
module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  tags         = var.tags

  expired_days    = 14
  max_image_count = 5
}

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  tags         = var.tags

  lambda_scheduler_function_arn = module.lambda_noti.function_arn
  sqs_dlq_arn                   = module.sqs_dlq.queue_arn
}

module "lambda_api" {
  source = "../../modules/lambda"

  project_name = var.project_name
  tags         = var.tags

  function_name_suffix = "api"

  image_command = ["dist/lambda/api.handler"]

  lambda_role_arn = module.iam.lambda_role_arn

  lambda_function_config = {
    image_uri     = "${module.ecr.repository_urls}:${var.image_tag}"
    memory        = 1024
    timeout       = 30
    architectures = ["arm64"]

    environment = var.lambda_api_env
  }
}

module "lambda_noti" {
  source = "../../modules/lambda"

  project_name = var.project_name
  tags         = var.tags

  function_name_suffix = "notification"

  image_command = ["dist/lambda/notification.handler"]

  lambda_role_arn = "${module.ecr.repository_urls}:${var.image_tag}"

  lambda_function_config = {
    image_uri     = module.ecr.repository_urls
    memory        = 512
    timeout       = 120
    architectures = ["arm64"]

    environment = {}
  }

  reserved_concurrent_executions = 1
}

module "apigw" {
  source = "../../modules/api_gateway"

  project_name = var.project_name
  tags         = var.tags

  api_routes = {
    prefix_path       = "/"
    lambda_invoke_arn = module.lambda_api.function_invoke_arn
    lambda_arn        = module.lambda_api.function_arn
  }
}

module "sqs_dlq" {
  source = "../../modules/sqs"

  project_name = var.project_name
  tags         = var.tags
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name = var.project_name
  tags         = var.tags
  region       = var.region

  sns_email = var.sns_email

  lambda_function_names = {
    api_function  = module.lambda_api.function_name
    noti_function = module.lambda_noti.function_name
  }

  apigw = {
    api_name  = module.apigw.api_name
    api_id    = module.apigw.api_id
    api_stage = module.apigw.stage_name
  }
}

module "notification_schedule_08h" {
  source = "../../modules/event_bridge"

  project_name = var.project_name
  name_suffix  = "08h"
  tags         = var.tags

  target_arn = module.lambda_noti.function_arn
  role_arn   = module.iam.scheduler_role_arn

  schedule_expression = "cron(0 8 * * ? *)"

  input = jsonencode({
    source = "sis.scheduler"
    type   = "notification-cron"
    region = "ap-southeast-1"
    detail = {
      job = "generate-reorder-suggestions"
    }
  })

  dead_letter_arn = module.sqs_dlq.queue_arn
}

module "notification_schedule_20h" {
  source = "../../modules/event_bridge"

  project_name = var.project_name
  name_suffix  = "20h"
  tags         = var.tags

  target_arn = module.lambda_noti.function_arn
  role_arn   = module.iam.scheduler_role_arn

  schedule_expression = "cron(0 20 * * ? *)"

  input = jsonencode({
    source = "sis.scheduler"
    type   = "notification-cron"
    region = "ap-southeast-1"
    detail = {
      job = "scan-low-stock"
    }
  })

  dead_letter_arn = module.sqs_dlq.queue_arn
}
