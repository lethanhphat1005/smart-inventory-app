output "vpc_id" {
  description = "ID của VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Danh sách ID của public subnets."
  value       = module.networking.public_subnet_ids
}

output "backend_security_group_id" {
  description = "ID của security group gắn cho EC2 backend."
  value       = module.networking.backend_security_group_id
}

output "ec2_eip_allocation_id" {
  description = "Allocation ID của Elastic IP."
  value       = module.networking.ec2_eip_allocation_id
}

output "ec2_eip_public_ip" {
  description = "Public IP của Elastic IP."
  value       = module.networking.ec2_eip_public_ip
}

output "ec2_role_name" {
  description = "Tên IAM role gắn cho EC2."
  value       = module.iam.ec2_role_name
}

output "ec2_role_arn" {
  description = "ARN IAM role gắn cho EC2."
  value       = module.iam.ec2_role_arn
}

output "iam_instance_profile_name" {
  description = "Tên IAM instance profile gắn cho EC2."
  value       = module.iam.instance_profile_name
}

output "iam_instance_profile_arn" {
  description = "ARN IAM instance profile gắn cho EC2."
  value       = module.iam.instance_profile_arn
}

output "ec2_instance_id" {
  description = "ID của EC2 instance."
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP của EC2 instance."
  value       = module.ec2.public_ip
}

output "ec2_private_ip" {
  description = "Private IP của EC2 instance."
  value       = module.ec2.private_ip
}

output "ec2_key_pair_name" {
  description = "Tên key pair dùng để launch EC2."
  value       = module.ec2.key_pair_name
}

output "cloudwatch_dashboard_name" {
  description = "Tên CloudWatch dashboard."
  value       = module.cloudwatch.dashboard_name
}

output "backend_log_group_name" {
  description = "Tên CloudWatch log group của backend."
  value       = module.cloudwatch.backend_log_group_name
}

output "backend_log_group_arn" {
  description = "ARN CloudWatch log group của backend."
  value       = module.cloudwatch.backend_log_group_arn
}

output "nginx_log_group_name" {
  description = "Tên CloudWatch log group của nginx."
  value       = module.cloudwatch.nginx_log_group_name
}

output "cpu_alarm_name" {
  description = "Tên CloudWatch alarm CPU."
  value       = module.cloudwatch.cpu_alarm_name
}

output "status_check_alarm_name" {
  description = "Tên CloudWatch alarm status check."
  value       = module.cloudwatch.status_check_alarm_name
}

output "disk_alarm_name" {
  description = "Tên CloudWatch alarm disk."
  value       = module.cloudwatch.disk_alarm_name
}