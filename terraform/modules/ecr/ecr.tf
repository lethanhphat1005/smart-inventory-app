resource "aws_ecr_repository" "backend" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE" # Cho phép image tag có thể thay đổi

  image_scanning_configuration {
    scan_on_push = true # Tự động quét lỗ hổng khi đẩy image lên
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}"
  })
}

resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.backend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Delete untagged images older than X days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.expired_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep only maximum X images left"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
