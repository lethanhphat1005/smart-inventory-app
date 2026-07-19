output "repository_urls" {
  description = "ECR repo URL"
  value       = aws_ecr_repository.backend.repository_url
}

output "repository_arns" {
  description = "ECR repo ARN"
  value       = aws_ecr_repository.backend.arn
}
