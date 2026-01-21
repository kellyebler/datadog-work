# Terraform Infrastructure

Terraform configurations for provisioning AWS infrastructure and Datadog resources.

## Modules

### aws/

AWS infrastructure including:
- VPC with public and private subnets across multiple AZs
- Internet Gateway and NAT Gateway
- EKS cluster (v1.31) with Fargate profiles
- EC2 instances

Uses Terraform Cloud workspace: `datadog-work`

See [aws/README.md](./aws/README.md) for module details.

### datadog/

Datadog resource management including:
- Synthetic tests (ICMP, API)
- Monitors and dashboards (extensible)

Uses Terraform Cloud workspace: `datadog`

## Prerequisites

- Terraform >= 1.0
- AWS credentials configured
- Datadog API and App keys (for datadog module)
- Terraform Cloud account (optional, for remote state)

## Usage

```bash
# Initialize and plan AWS infrastructure
cd aws
terraform init
terraform plan

# Initialize and plan Datadog resources
cd ../datadog
terraform init
terraform plan
```

## State Management

Both modules use Terraform Cloud for remote state storage. Update the `cloud` block in each `main.tf` to use your own organization and workspace names, or remove it to use local state.

## Related

- [eks_fargate_example/](../eks_fargate_example/) - Uses the AWS infrastructure from this module
