# Datadog SE Work

A collection of configurations, examples, and utilities from my work as a Datadog Solutions Engineer. This repository showcases practical implementations and solutions for common customer scenarios.

## Repository Structure

```
.
├── agent/                    # Datadog Agent configurations
├── ansible/                  # Ansible playbooks for Datadog deployment
├── eks_fargate_example/      # EKS Fargate with Datadog APM (OTLP)
├── estimated_usage_metrics/  # Usage monitoring and alerting
├── mongodb/                  # MongoDB integration config
├── postgres/                 # PostgreSQL verification utilities
├── rum/                      # Real User Monitoring injection script
└── terraform/                # Infrastructure as Code examples
    ├── aws/                  # AWS infrastructure (VPC, EKS, EC2)
    └── datadog/              # Datadog resource management
```

## Quick Links

| Directory | Description |
|-----------|-------------|
| [agent/](./agent/) | Minimal configuration templates for Datadog Agent integrations |
| [eks_fargate_example/](./eks_fargate_example/) | Complete EKS Fargate + OpenTelemetry APM demo |
| [estimated_usage_metrics/](./estimated_usage_metrics/) | Dashboard queries for tracking MTD usage vs. committed spend |
| [terraform/](./terraform/) | Terraform modules for AWS infrastructure and Datadog resources |

## Highlights

### EKS Fargate with OpenTelemetry

The `eks_fargate_example/` directory contains a full working demo of:
- Flask application instrumented with OpenTelemetry SDK
- Datadog Agent sidecar pattern for Fargate
- OTLP trace collection (gRPC on port 4317)
- Unified service tagging for trace-infrastructure correlation

### Agent Configuration Templates

The `agent/` directory provides minimal, well-documented configuration files for:
- Main `datadog.yaml` with logs and process monitoring enabled
- PostgreSQL Database Monitoring (DBM) setup
- RabbitMQ integration
- MongoDB with TLS configuration

### Usage Monitoring

The `estimated_usage_metrics/` directory shows how to create dashboards and alerts for tracking cumulative monthly usage against committed spend—a common customer request.

## Getting Started

Each directory contains its own README with specific instructions. For infrastructure provisioning:

```bash
# AWS infrastructure (VPC, EKS, EC2)
cd terraform/aws
terraform init && terraform plan

# Datadog resources (Synthetics tests, monitors)
cd terraform/datadog
terraform init && terraform plan
```

## Contributing

This is a personal showcase repository. Feel free to open issues if you have questions about any of the configurations or would like to discuss implementation details.

## License

This repository is intended for educational and demonstration purposes.
