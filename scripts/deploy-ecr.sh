#!/bin/bash
set -euo pipefail

AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="352818908895"
ECR_REPOSITORY="aws-terraform-ansible-demo"
IMAGE_TAG="${1:?Usage: deploy-ecr.sh <image-tag>}"
CONTAINER_NAME="aws-terraform-ansible-demo"
IMAGE_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"

echo "Deploying ${IMAGE_URI}"

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login \
      --username AWS \
      --password-stdin \
      "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

docker pull "$IMAGE_URI"

docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -p 80:8000 \
  "$IMAGE_URI"

sleep 5

curl --fail --connect-timeout 10 \
  http://localhost/health

echo
echo "Deployment successful."
docker ps --filter "name=${CONTAINER_NAME}"
