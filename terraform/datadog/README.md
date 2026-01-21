# Terraform: Datadog Resources

Terraform configuration for managing Datadog resources as code.

## Overview

This module demonstrates how to provision Datadog resources using the official Datadog Terraform provider.

## Current Resources

### Synthetic ICMP Test

A simple ping test configured to:
- Monitor `example.com` availability
- Run every 15 minutes from `aws:eu-central-1`
- Alert on packet loss or high latency (>1000ms avg)
- Retry 3 times with 5-minute intervals before alerting

## Prerequisites

1. Datadog API and App keys
2. Create a `terraform.tfvars` file (not committed):
   ```hcl
   datadog_api_key = "your-api-key"
   datadog_app_key = "your-app-key"
   ```

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Extending

Add additional resources to `main.tf`:
- Monitors: `datadog_monitor`
- Dashboards: `datadog_dashboard_json`
- SLOs: `datadog_service_level_objective`
- Log pipelines: `datadog_logs_pipeline`

## Related Documentation

- [Datadog Terraform Provider](https://registry.terraform.io/providers/DataDog/datadog/latest/docs)
- [Synthetics Test Resource](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/synthetics_test)
