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

  lambda_scheduler_function_arn = module.lambda_cron.function_arn
  sqs_dlq_arn                   = module.sqs_dlq.queue_arn

  ssm_parameter_arns = [
    module.ssm_parameters.parameter_arns["firebase_service_account"],
    module.ssm_parameters.parameter_arns["database_url"],
    module.ssm_parameters.parameter_arns["supabase_service_role_key"],
    module.ssm_parameters.parameter_arns["redis_url"],
    module.ssm_parameters.parameter_arns["groq_api_key"],
  ]

  function_ssm_parameter_arns = {
    api_function = [
      module.ssm_parameters.parameter_arns["firebase_service_account"],
      module.ssm_parameters.parameter_arns["database_url"],
      module.ssm_parameters.parameter_arns["supabase_service_role_key"],
      module.ssm_parameters.parameter_arns["redis_url"],
      module.ssm_parameters.parameter_arns["groq_api_key"],
    ]
    cron_function = [
      module.ssm_parameters.parameter_arns["firebase_service_account"],
      module.ssm_parameters.parameter_arns["database_url"],
    ]
  }
}

module "ssm_parameters" {
  source = "../../modules/ssm_parameter"

  project_name = var.project_name
  tags         = var.tags

  parameter_name_prefix = "/sis/staging"

  parameters_config = {
    firebase_service_account = {
      name  = "service-account-key"
      value = file(var.secret_parameters.service_account_key_file)
    }
    database_url = {
      name  = "database-url"
      value = var.secret_parameters.database_url
    }
    supabase_service_role_key = {
      name  = "supabase-service-role-key"
      value = var.secret_parameters.supabase_service_role_key
    }
    redis_url = {
      name  = "redis-url"
      value = var.secret_parameters.redis_url
    }
    groq_api_key = {
      name  = "groq-api-key"
      value = var.secret_parameters.groq_api_key
    }
  }
}

module "lambda_api" {
  source = "../../modules/lambda"

  project_name = var.project_name
  tags         = var.tags

  function_name_suffix = "api"

  image_command = ["dist/lambda/api.handler"]

  lambda_role_arn = module.iam.api_lambda_role_arn

  lambda_function_config = {
    image_uri     = "${module.ecr.repository_urls}:${var.image_tag}"
    memory        = 1024
    timeout       = 30
    architectures = ["arm64"]

    environment = merge(var.lambda_api_env, {
      FIREBASE_SERVICE_ACCOUNT_PARAMETER  = module.ssm_parameters.parameter_names["firebase_service_account"]
      DATABASE_URL_PARAMETER              = module.ssm_parameters.parameter_names["database_url"]
      SUPABASE_SERVICE_ROLE_KEY_PARAMETER = module.ssm_parameters.parameter_names["supabase_service_role_key"]
      REDIS_URL_PARAMETER                 = module.ssm_parameters.parameter_names["redis_url"]
      GROQ_API_KEY_PARAMETER              = module.ssm_parameters.parameter_names["groq_api_key"]
    })
  }
}

module "lambda_cron" {
  source = "../../modules/lambda"

  project_name = var.project_name
  tags         = var.tags

  function_name_suffix = "notification"

  image_command = ["dist/lambda/notification.handler"]

  lambda_role_arn = module.iam.cron_lambda_role_arn

  lambda_function_config = {
    image_uri     = "${module.ecr.repository_urls}:${var.image_tag}"
    memory        = 512
    timeout       = 120
    architectures = ["arm64"]
    environment = merge(var.lambda_noti_env, {
      FIREBASE_SERVICE_ACCOUNT_PARAMETER = module.ssm_parameters.parameter_names["firebase_service_account"]
      DATABASE_URL_PARAMETER             = module.ssm_parameters.parameter_names["database_url"]
    })
  }

  async_invoke_config = {
    maximum_event_age_in_seconds = 3000
    maximum_retry_attempts       = 2
    on_failure_destination_arn   = module.sqs_dlq.queue_arn
  }
}

module "apigw" {
  source = "../../modules/api_gateway"

  project_name = var.project_name
  tags         = var.tags

  api_routes = {
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
    cron_function = module.lambda_cron.function_name
  }

  apigw = {
    api_name  = module.apigw.api_name
    api_id    = module.apigw.api_id
    api_stage = module.apigw.stage_name
  }

  notification_dlq_name = module.sqs_dlq.queue_name
}

module "notification_schedule_08h" {
  source = "../../modules/event_bridge"

  project_name = var.project_name
  name_suffix  = "08h"
  tags         = var.tags

  target_arn = module.lambda_cron.function_arn
  role_arn   = module.iam.scheduler_role_arn

  schedule_expression = "cron(0 8 * * ? *)"

  input = jsonencode({
    source = "sis.scheduler"
    job    = "generate-reorder-suggestions"
  })

  dead_letter_arn = module.sqs_dlq.queue_arn
}

module "notification_schedule_20h" {
  source = "../../modules/event_bridge"

  project_name = var.project_name
  name_suffix  = "20h"
  tags         = var.tags

  target_arn = module.lambda_cron.function_arn
  role_arn   = module.iam.scheduler_role_arn

  schedule_expression = "cron(0 20 * * ? *)"

  input = jsonencode({
    source = "sis.scheduler"
    job    = "scan-low-stock"
  })

  dead_letter_arn = module.sqs_dlq.queue_arn
}
