output "vpc_id" {
  description = "ID của VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block của VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Danh sách ID của public subnets"
  value       = aws_subnet.public[*].id
}

output "public_route_table_id" {
  description = "ID của public route table"
  value       = aws_route_table.public.id
}

output "internet_gateway_id" {
  description = "ID của Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "backend_security_group_id" {
  description = "ID của security group gắn cho EC2 backend"
  value       = aws_security_group.backend.id
}
