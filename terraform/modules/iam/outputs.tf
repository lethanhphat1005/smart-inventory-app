output "ec2_role_name" {
  description = "Tên IAM role gán cho EC2."
  value       = aws_iam_role.ec2.name
}

output "ec2_role_arn" {
  description = "ARN IAM role gán cho EC2."
  value       = aws_iam_role.ec2.arn
}

output "instance_profile_name" {
  description = "Tên IAM instance profile gán cho EC2."
  value       = aws_iam_instance_profile.ec2.name
}

output "instance_profile_arn" {
  description = "ARN IAM instance profile gán cho EC2."
  value       = aws_iam_instance_profile.ec2.arn
}