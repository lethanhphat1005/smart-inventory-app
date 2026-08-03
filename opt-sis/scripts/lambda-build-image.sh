#!/usr/bin/env bash
set -e

AWS_REGION="${AWS_REGION:-ap-southeast-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-430118860011}"
ECR_REPOSITORY="${ECR_REPOSITORY:-storix-backend}"
IMAGE_TAG="${1:-latest}"

aws ecr get-login-password --region "$AWS_REGION" \
| docker login \
    --username AWS \
    --password-stdin \
    "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

docker buildx build \
  --builder multiarch-builder \
  --platform linux/arm64 \
  --provenance=false \
  --sbom=false \
  -f Dockerfile.lambda \
  -t "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:$IMAGE_TAG" \
  --push \
  .
