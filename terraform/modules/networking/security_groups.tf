# SECURITY GROUP LAMBDA
resource "aws_security_group" "lambda_sg" {
  name        = "${var.project_name}-lambda-sg"
  vpc_id      = aws_vpc.main.id
  description = "Lambda security group"

  tags = merge(var.tags, {
    Name = "${var.project_name}-lambda-sg"
  })
}

resource "aws_vpc_security_group_egress_rule" "lambda_allow_http" {
  security_group_id = aws_security_group.lambda_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
