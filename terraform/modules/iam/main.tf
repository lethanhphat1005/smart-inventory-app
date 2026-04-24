resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2-role"
  })
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.ec2.name

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2-instance-profile"
  })
}

# Gắn managed policy chuẩn của AWS cho CloudWatch Agent
# CloudWatch Agent sẽ đọc và lưu các log file và gửi lên CloudWatch
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  count = var.enable_cloudwatch_agent_policy ? 1 : 0

  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Quyền đọc secret từ Secrets Manager
# resource "aws_iam_policy" "secret" {
#   name        = "${var.project_name}-secret-policy"
#   description = "Permission to read secrets from Secrets Manager"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow"
#       Action = [
#         "secretsmanager:GetSecretValue"
#       ]
#       Resource = local.secret_arns
#     }]
#   })

#   tags = merge(var.tags, {
#     Name = "${var.project_name}-secret-policy"
#   })
# }

# resource "aws_iam_role_policy_attachment" "secret" {
#   role       = aws_iam_role.ec2.name
#   policy_arn = aws_iam_policy.secret.arn
# }