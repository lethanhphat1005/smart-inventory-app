resource "aws_security_group" "backend" {
  name        = "${var.project_name}-backend-sg"
  description = "Security group for EC2 backend SIS"
  vpc_id      = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-backend-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "backend_ssh" {
  for_each = toset(var.allowed_ssh_cidrs)

  description       = "Allow SSH from device IP"
  security_group_id = aws_security_group.backend.id
  cidr_ipv4         = each.value
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"

}

resource "aws_vpc_security_group_ingress_rule" "backend_http" {
  description       = "Allow HTTP public"
  security_group_id = aws_security_group.backend.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "backend_https" {
  description       = "Allow HTTPS public"
  security_group_id = aws_security_group.backend.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_all_outbound" {
  security_group_id = aws_security_group.backend.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}