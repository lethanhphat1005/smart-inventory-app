locals {
  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.hosted_zone_id
}

# Hosted zone chứa record DNS
# Tạo khi domain quản lý bởi AWS
# Không tạo khi domain mua bên ngoài (Namecheap, GoDaddy)
resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0

  name = var.domain_name

  tags = merge(var.tags, {
    Name = "${var.project_name}-zone"
  })
}

# Record DNS cho backend để map tới EC2 public IP
resource "aws_route53_record" "backend" {
  zone_id = local.zone_id
  name    = var.subdomain
  type    = "A"     # Dùng type A thay vì ALB
  ttl     = var.ttl # Thời gian cache DNS

  records = [var.ec2_public_ip]
}

# Record dùng domain name chính
resource "aws_route53_record" "root" {
  count = var.create_root_record ? 1 : 0

  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = var.ttl

  records = [var.ec2_public_ip] # Trỏ tới IP web frontend nếu có
}