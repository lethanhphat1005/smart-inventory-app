resource "aws_key_pair" "main" {
  count = var.create_key_pair ? 1 : 0

  key_name   = var.key_pair_name
  public_key = var.public_key

  tags = merge(var.tags, {
    Name = "${var.project_name}-key-pair"
  })
}