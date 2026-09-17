#!/bin/bash
# Boot script for app instances.  Everything environment-specific comes from
# SSM Parameter Store so the launch template stays identical across deploys.
set -euo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

dnf install -y docker
systemctl enable --now docker

REGION="${region}"
PREFIX="${ssm_prefix}"
ECR_URL="${ecr_url}"
PORT="${container_port}"

param() {
  aws ssm get-parameter --region "$REGION" --name "$PREFIX/$1" --with-decryption --query 'Parameter.Value' --output text
}

DB_URL="$(param db/url)"
DB_USER="$(param db/user)"
DB_PASS="$(param db/password)"
IMAGE_TAG="$(param app/image_tag)"

aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$${ECR_URL%%/*}"

docker pull "$ECR_URL:$IMAGE_TAG"
docker rm -f app 2>/dev/null || true
docker run -d --name app --restart unless-stopped \
  -p "$PORT:8080" \
  -e DB_URL="$DB_URL" -e DB_USER="$DB_USER" -e DB_PASS="$DB_PASS" \
  -e APP_VERSION="$IMAGE_TAG" \
  --log-driver=journald \
  "$ECR_URL:$IMAGE_TAG"
