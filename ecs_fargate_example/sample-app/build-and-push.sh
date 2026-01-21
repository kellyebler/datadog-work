#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== ECS Fargate Sample App - Build and Push ===${NC}"

# Get AWS region from environment or use default
AWS_REGION=${AWS_REGION:-us-west-2}
echo -e "${YELLOW}Using AWS Region: ${AWS_REGION}${NC}"

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo -e "${RED}Error: Could not determine AWS Account ID. Is AWS CLI configured?${NC}"
    exit 1
fi
echo -e "${YELLOW}AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"

# ECR repository details
ECR_REPO_NAME="sample-app"
ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"

# Check if ECR repository exists
if ! aws ecr describe-repositories --repository-names ${ECR_REPO_NAME} --region ${AWS_REGION} >/dev/null 2>&1; then
    echo -e "${RED}Error: ECR repository '${ECR_REPO_NAME}' not found in region ${AWS_REGION}${NC}"
    echo -e "${YELLOW}Please run 'terraform apply' first to create the infrastructure${NC}"
    exit 1
fi

echo -e "${GREEN}ECR Repository: ${ECR_URL}${NC}"

# Authenticate Docker to ECR
echo -e "${YELLOW}Authenticating with ECR...${NC}"
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}

# Build Docker image
echo -e "${YELLOW}Building Docker image...${NC}"
docker build -t ${ECR_REPO_NAME}:latest .

# Tag image for ECR
echo -e "${YELLOW}Tagging image for ECR...${NC}"
docker tag ${ECR_REPO_NAME}:latest ${ECR_URL}:latest

# Push image to ECR
echo -e "${YELLOW}Pushing image to ECR...${NC}"
docker push ${ECR_URL}:latest

echo -e "${GREEN}=== Build and push complete! ===${NC}"
echo -e "${GREEN}Image pushed to: ${ECR_URL}:latest${NC}"
echo ""
echo -e "${YELLOW}To deploy to ECS, update the service with:${NC}"
echo "aws ecs update-service --cluster sample-app-cluster --service sample-app-service --force-new-deployment --region ${AWS_REGION}"
