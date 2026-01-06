#!/bin/bash
set -e

# Configuration
AWS_REGION="us-west-2"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO_NAME="sample-otel-app"
IMAGE_TAG="latest"

echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "AWS Region: $AWS_REGION"
echo "ECR Repository: $ECR_REPO_NAME"

# Temporarily disable credential store for ECR login
# This avoids the docker-credential-osxkeychain error while preserving Colima config
mkdir -p ~/.docker
if [ -f ~/.docker/config.json ]; then
  cp ~/.docker/config.json ~/.docker/config.json.backup
  # Remove only the credsStore line, keep everything else (important for Colima)
  cat ~/.docker/config.json | jq 'del(.credsStore)' > ~/.docker/config.json.tmp
  mv ~/.docker/config.json.tmp ~/.docker/config.json
else
  echo "{}" > ~/.docker/config.json
fi

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Create ECR repository if it doesn't exist
echo "Creating ECR repository (if it doesn't exist)..."
aws ecr create-repository --repository-name $ECR_REPO_NAME --region $AWS_REGION 2>/dev/null || true

# Build the Docker image (native AMD64 on EC2)
echo "Building Docker image..."
docker build \
  -t $ECR_REPO_NAME:$IMAGE_TAG \
  -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG \
  .

# Push to ECR
echo "Pushing to ECR..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG

# Restore original config if it existed
if [ -f ~/.docker/config.json.backup ]; then
  mv ~/.docker/config.json.backup ~/.docker/config.json
fi

echo ""
echo "✅ Successfully pushed image to:"
echo "   $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG"
echo ""
echo "Now update deployment.yaml with this image URL and run:"
echo "   kubectl apply -f deployment.yaml"
