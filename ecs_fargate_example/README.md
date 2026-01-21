# ECS Fargate with Datadog Monitoring

This example demonstrates how to deploy a containerized application on AWS ECS Fargate with Datadog monitoring and custom tags for telemetry attribution.

## Overview

This setup includes:
- Simple Flask application running on ECS Fargate
- Datadog Agent as a sidecar container for metrics, logs, and traces collection
- Custom tags applied to all telemetry for attribution and filtering
- Complete Terraform infrastructure for VPC, ECS cluster, and load balancing

## Architecture

```
┌─────────────────────────────────────────┐
│   Application Load Balancer (Public)    │
└──────────────┬──────────────────────────┘
               │
     ┌─────────┴─────────┐
     │                   │
┌────▼─────┐      ┌────▼─────┐
│  Task 1  │      │  Task 2  │  (Private Subnets)
│          │      │          │
│ ┌──────┐ │      │ ┌──────┐ │
│ │ App  │ │      │ │ App  │ │
│ └──────┘ │      │ └──────┘ │
│          │      │          │
│ ┌──────┐ │      │ ┌──────┐ │
│ │ DD   │ │      │ │ DD   │ │
│ │Agent │ │      │ │Agent │ │
│ └──────┘ │      │ └──────┘ │
└──────────┘      └──────────┘
```

## Custom Tags

The Datadog Agent is configured with the following custom tags in the task definition:

```json
"DD_TAGS": "env:production service:sample-app version:1.0.0 team:platform region:us-west-2 cost-center:engineering"
```

These tags will be applied to all metrics, logs, and traces collected from the application, allowing you to:
- Filter and aggregate telemetry by environment, service, or team
- Track costs by cost center
- Correlate infrastructure and application performance by region
- Monitor deployments by version

## Prerequisites

- AWS account with appropriate permissions
- Terraform installed (>= 1.0)
- AWS CLI configured
- Docker installed
- Datadog account and API key

## Quick Start

### 1. Deploy Infrastructure

```bash
cd terraform

# Create terraform.tfvars file with your configuration
cat > terraform.tfvars <<EOF
aws_region       = "us-west-2"
environment      = "production"
datadog_api_key  = "your-datadog-api-key"
datadog_site     = "datadoghq.com"
desired_count    = 2
team_tag         = "platform"
cost_center_tag  = "engineering"
EOF

# Initialize and apply Terraform
terraform init
terraform plan
terraform apply
```

### 2. Build and Push Docker Image

```bash
cd ../sample-app

# Get ECR repository URL from Terraform output
ECR_URL=$(cd ../terraform && terraform output -raw ecr_repository_url)

# Authenticate with ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $ECR_URL

# Build and push the image
docker build -t sample-app .
docker tag sample-app:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

### 3. Deploy the Application

The ECS service is automatically created by Terraform. After pushing the Docker image, the tasks will start automatically.

```bash
# Check service status
aws ecs describe-services \
  --cluster sample-app-cluster \
  --services sample-app-service \
  --region us-west-2

# Check task status
aws ecs list-tasks \
  --cluster sample-app-cluster \
  --service-name sample-app-service \
  --region us-west-2

# Get ALB DNS name
cd terraform
terraform output alb_dns_name
```

### 4. Test the Application

```bash
# Get the ALB DNS name
ALB_DNS=$(cd terraform && terraform output -raw alb_dns_name)

# Test endpoints
curl http://$ALB_DNS/
curl http://$ALB_DNS/api/users
curl http://$ALB_DNS/api/process
curl http://$ALB_DNS/health
```

## Application Endpoints

- `GET /` - Hello world endpoint with service metadata
- `GET /api/users` - Returns a list of users
- `GET /api/process` - Simulates data processing
- `GET /health` - Health check endpoint

## Datadog Integration

### Viewing Metrics

In Datadog, you can view metrics from your ECS Fargate tasks:

1. Navigate to **Infrastructure > Containers**
2. Filter by tag: `service:sample-app` or `team:platform`
3. View container metrics, resource utilization, and health

### Custom Tag Filtering

Use custom tags in Datadog to filter and aggregate:

```
# Filter by team
team:platform

# Filter by cost center
cost-center:engineering

# Filter by environment and service
env:production AND service:sample-app

# Aggregate costs by tag
sum:aws.ecs.cost by {cost-center}
```

### Log Management

Container logs are automatically collected by the Datadog Agent:

1. Navigate to **Logs > Explorer**
2. Filter by: `service:sample-app`
3. View application and agent logs with custom tags

### Custom Metrics

To add custom metrics from your application, you can use DogStatsD:

```python
from datadog import initialize, statsd

# Initialize DogStatsD
options = {
    'statsd_host': 'localhost',
    'statsd_port': 8125
}
initialize(**options)

# Send custom metrics
statsd.increment('app.requests', tags=['endpoint:/api/users'])
statsd.histogram('app.response_time', 0.025)
```

## Task Definition Configuration

The ECS task definition includes two containers:

### Application Container
- Runs the Flask application on port 8080
- Environment variables: `DD_SERVICE`, `DD_ENV`, `DD_VERSION`
- Health check on `/health` endpoint
- Logs sent to CloudWatch and collected by Datadog Agent

### Datadog Agent Container
- Receives metrics via DogStatsD (UDP 8125)
- Collects logs from all containers in the task
- Auto-discovers services and collects container metrics
- Configured for ECS Fargate mode with `ECS_FARGATE=true`
- Custom tags applied via `DD_TAGS` environment variable

## Modifying Custom Tags

To change the custom tags applied to your telemetry:

### Option 1: Update Terraform Variables

Edit `terraform/variables.tf` or your `terraform.tfvars`:

```hcl
team_tag        = "your-team-name"
cost_center_tag = "your-cost-center"
environment     = "staging"
```

Then apply the changes:

```bash
cd terraform
terraform apply
```

### Option 2: Update Task Definition Directly

Edit the `DD_TAGS` environment variable in `terraform/main.tf`:

```hcl
{
  name  = "DD_TAGS"
  value = "env:${var.environment} service:sample-app custom-tag:value"
}
```

## Monitoring Best Practices

1. **Use Consistent Tagging**: Apply the same tag schema across all services
2. **Tag by Business Unit**: Use tags like `team` and `cost-center` for attribution
3. **Version Your Deployments**: Include `version` tags to track deployment impact
4. **Environment Separation**: Use `env` tags to separate production from staging
5. **Resource Attribution**: Tag by region or availability zone for cost analysis

## Troubleshooting

### Tasks Not Starting

```bash
# Check ECS events
aws ecs describe-services \
  --cluster sample-app-cluster \
  --services sample-app-service \
  --region us-west-2 \
  | jq '.services[0].events'

# Check task logs
aws logs tail /ecs/sample-app-fargate --follow
```

### Datadog Agent Not Reporting

```bash
# Check agent container logs
aws ecs describe-tasks \
  --cluster sample-app-cluster \
  --tasks $(aws ecs list-tasks --cluster sample-app-cluster --service-name sample-app-service --output text --query 'taskArns[0]') \
  --region us-west-2

# View agent logs in CloudWatch
aws logs tail /ecs/sample-app-fargate --follow --filter-pattern "datadog-agent"
```

### Verifying Tags in Datadog

1. Navigate to **Infrastructure > Host Map**
2. Select a container from your service
3. Check the tags panel to verify custom tags are present
4. Search for your custom tags in the search bar (e.g., `team:platform`)

## Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy
```

## Cost Considerations

This setup includes:
- 2 Fargate tasks (0.5 vCPU, 1GB memory each)
- Application Load Balancer
- NAT Gateway (for private subnet internet access)
- CloudWatch Logs

Estimated monthly cost: ~$60-80 USD (varies by region and usage)

## Additional Resources

- [Datadog ECS Fargate Integration](https://docs.datadoghq.com/integrations/ecs_fargate/)
- [Unified Service Tagging](https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging/)
- [AWS ECS Fargate Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html)
- [Datadog Agent Configuration](https://docs.datadoghq.com/agent/configuration/)
