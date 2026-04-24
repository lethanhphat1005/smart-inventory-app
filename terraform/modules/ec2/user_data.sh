#!/bin/bash
set -euxo pipefail

# Update hệ thống
dnf update -y

exec > >(tee /var/log/user-data.log) 2>&1

# Cài package cần thiết
dnf install -y docker git

# Enable và start Docker
systemctl enable docker
systemctl start docker

# Cho ec2-user dùng docker không cần sudo
usermod -aG docker ec2-user

# Init Docker Swarm (chỉ khi chưa active)
if ! docker info 2>/dev/null | grep -q 'Swarm: active'; then
  docker swarm init || true
fi

# Tạo thư mục project
mkdir -p /opt/sis/env
mkdir -p /opt/sis/nginx
mkdir -p /opt/sis/secrets
mkdir -p /opt/sis/stacks
mkdir -p /opt/sis/scripts

# set quyền
chown -R ec2-user:ec2-user /opt/sis