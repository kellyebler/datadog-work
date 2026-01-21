# CLAUDE.md

This file provides guidance to Claude Code when working with this ECS Fargate example.

## Repository Overview

This directory contains a demonstration of AWS ECS Fargate with Datadog monitoring. The key focus is showing how to apply **custom tags** to incoming telemetry for attribution, filtering, and cost tracking.

## Key Components

### 1. Sample Application (`sample-app/`)
- Simple Flask web application with 4 endpoints
- Minimal dependencies (Flask only)
- Environment variables for unified service tagging (`DD_SERVICE`, `DD_ENV`, `DD_VERSION`)

### 2. Terraform Infrastructure (`terraform/`)
- Complete VPC setup with public/private subnets across 2 availability zones
- ECS Fargate cluster with Container Insights enabled
- Application Load Balancer for traffic distribution
- ECR repository for container images
- Security groups and IAM roles
- Task definition with Datadog Agent sidecar

### 3. Custom Tags Configuration

The critical configuration for custom tags is in `terraform/main.tf` within the Datadog Agent container definition:

```hcl
{
  name  = "DD_TAGS"
  value = "env:${var.environment} service:sample-app version:1.0.0 team:${var.team_tag} region:${var.aws_region} cost-center:${var.cost_center_tag}"
}
```

These tags are applied to ALL telemetry collected by the agent, including:
- Container metrics
- Custom application metrics
- Logs
- Future traces (if APM is enabled)

## Architecture Decisions

### Why Sidecar Pattern?
ECS Fargate requires the Datadog Agent to run as a sidecar container within each task. Unlike EC2-based ECS, you cannot run a single agent on the host.

### Why These Specific Tags?
The example includes common enterprise tagging requirements:
- `env` - Environment separation (production, staging, etc.)
- `service` - Service identification
- `version` - Deployment tracking
- `team` - Organizational attribution
- `region` - Geographic cost allocation
- `cost-center` - Financial tracking and chargeback

### Network Design
- **Public Subnets**: Host the ALB only
- **Private Subnets**: Run ECS tasks (security best practice)
- **NAT Gateway**: Required for private subnet internet access (Datadog API, ECR pulls)

## Common Operations

### Adding New Custom Tags

To add new custom tags, modify the `DD_TAGS` value in `terraform/main.tf`:

```hcl
value = "existing-tags new-tag:value another-tag:value"
```

Consider adding variables in `variables.tf` for dynamic tags:

```hcl
variable "new_tag" {
  description = "Description of new tag"
  type        = string
  default     = "default-value"
}
```

### Updating the Application

1. Build new Docker image
2. Push to ECR with new tag (or `:latest`)
3. Update ECS service to force new deployment:
   ```bash
   aws ecs update-service \
     --cluster sample-app-cluster \
     --service sample-app-service \
     --force-new-deployment
   ```

### Viewing Custom Tags in Datadog

1. Infrastructure > Containers - filter by any custom tag
2. Logs Explorer - custom tags appear in log attributes
3. Metrics Explorer - group/filter by custom tags
4. Dashboards - use custom tags in template variables

## Important Configuration Details

### Datadog Agent Environment Variables

Required for Fargate:
- `ECS_FARGATE=true` - Enables Fargate-specific metrics collection
- `DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true` - Allows StatsD from other containers
- `DD_LOGS_ENABLED=true` - Enables log collection
- `DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true` - Collects logs from all task containers

Optional but recommended:
- `DD_CONTAINER_EXCLUDE=name:datadog-agent` - Prevents recursive agent monitoring
- `DD_TAGS` - **This is where custom tags are configured**

### Task Definition Resource Requirements

Current configuration:
- **Total Task**: 512 CPU units (0.5 vCPU), 1024 MB memory
- **Implicit split**: ECS allocates resources between containers

For production, consider:
- Explicit container resource limits
- Larger task sizes for higher traffic
- Auto-scaling based on CPU/memory metrics

### Health Checks

Two health checks are defined:
1. **Application**: `curl -f http://localhost:8080/health`
2. **Datadog Agent**: `agent health`

Both are critical for ECS to determine task health and perform replacements.

## Terraform State Management

This example uses **local state**. For production:
- Use remote state (S3 + DynamoDB)
- Enable state locking
- Consider Terraform Cloud/Enterprise

## What's NOT Included

This example intentionally excludes:
- **APM/Tracing**: Focus is on metrics and logs with custom tags
- **Auto-scaling**: Static task count for simplicity
- **HTTPS/SSL**: Uses HTTP for demonstration
- **Custom Metrics**: Application doesn't send DogStatsD metrics (but could)
- **Multi-region**: Single region deployment

## Extending This Example

### Adding APM

Add to application container environment:
```hcl
{
  name  = "DD_TRACE_ENABLED"
  value = "true"
}
{
  name  = "DD_AGENT_HOST"
  value = "localhost"
}
```

Instrument Python application with `ddtrace`.

### Adding Custom Metrics

Install `datadog` Python library and send metrics:
```python
from datadog import statsd
statsd.increment('custom.metric', tags=['custom:tag'])
```

### Adding Auto-scaling

Add to Terraform:
```hcl
resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
```

## Testing Custom Tags

After deployment, verify tags are applied:

1. **Via Datadog API**:
   ```bash
   curl -X GET "https://api.datadoghq.com/api/v1/metrics/list" \
     -H "DD-API-KEY: ${DD_API_KEY}" \
     -H "DD-APPLICATION-KEY: ${DD_APP_KEY}"
   ```

2. **Via Datadog UI**:
   - Infrastructure > Containers
   - Filter: `service:sample-app`
   - Inspect container tags

3. **Via Logs**:
   - Logs Explorer
   - Search: `service:sample-app`
   - Verify log facets include custom tags

## Common Issues

### Tags Not Appearing
- Verify `DD_TAGS` format (space-separated, colon for key:value)
- Check agent logs for parsing errors
- Ensure agent container is healthy and running

### Tasks Failing to Start
- Check IAM permissions (execution role needs ECR, CloudWatch access)
- Verify subnets have NAT gateway for internet access
- Confirm security groups allow ALB -> task communication

### No Metrics in Datadog
- Verify `DD_API_KEY` is correct
- Check `DD_SITE` matches your Datadog account
- Ensure `ECS_FARGATE=true` is set
- Review agent container logs for API errors

## Cost Optimization

Ways to reduce costs:
1. Use smaller task sizes during development
2. Reduce `desired_count` to 1 for testing
3. Use Fargate Spot for non-production (not shown in example)
4. Delete NAT Gateway when not in use (blocks internet access)
5. Reduce log retention in CloudWatch

## Security Considerations

Current security posture:
- ✅ Tasks run in private subnets
- ✅ Security groups restrict traffic
- ✅ IAM roles follow least privilege
- ✅ ECR image scanning enabled
- ❌ Datadog API key in plain text (should use Secrets Manager)
- ❌ HTTP only (should use HTTPS for production)

To improve:
```hcl
# Use AWS Secrets Manager for API key
secrets = [
  {
    name      = "DD_API_KEY"
    valueFrom = aws_secretsmanager_secret.datadog_api_key.arn
  }
]
```
