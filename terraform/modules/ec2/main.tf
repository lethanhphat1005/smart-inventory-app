data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"]

  # dùng bản AL2023 mới nhất phù hợp filter mỗi khi apply
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  effective_key_name = var.create_key_pair ? aws_key_pair.main[0].key_name : var.key_pair_name
}

resource "aws_instance" "main" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_instance_profile_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = local.effective_key_name
  associate_public_ip_address = var.has_associate_public_ip
  disable_api_termination     = var.has_disable_api_termination # ngăn việc xóa instance “nhầm tay” qua API/console khi bật lên

  user_data = templatefile("${path.module}/user_data.sh", {}) # chạy script khi khởi tạo lần đầu

  # cấu hình volume/disk của instane
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = true # mã hóa bằng KMS
    delete_on_termination = true # xóa khi instance bị xóa

    tags = merge(var.tags, {
      Name = "${var.project_name}-ec2-root-volume"
    })
  }

  # cấu hình lấy IMDS (metadata từ endpoint nội bộ aws)
  metadata_options {
    http_endpoint               = "enabled"  # cho phép ec2 đọc metadata
    http_tokens                 = "required" # phải có token mới gọi được
    http_put_response_hop_limit = 2          # số lớp network có thể đi qua (ec2 -> docker: 2 lớp)
    instance_metadata_tags      = "enabled"  # cho phép đọc tag của ec2 từ bên trong máy
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2"
  })
}

# gán EIP nếu có tạo
resource "aws_eip_association" "main" {
  count = var.enable_eip_association ? 1 : 0

  instance_id   = aws_instance.main.id
  allocation_id = var.eip_allocation_id
}