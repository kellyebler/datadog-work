# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Terraform project for managing AWS infrastructure with two local modules wired together:

- `module "networking"` (./networking) - VPC, subnets, internet gateway, and routing
- `module "compute"` (./compute) - EC2 instances and EKS resources

The repository uses **Terraform Cloud** with organization `kellyebler183451b6` and workspace `datadog-work`.

## Module Architecture

### Data Flow Between Modules

The networking module outputs subnet IDs that are consumed by the compute module. This is the key architectural pattern:

1. `networking/subnets.tf` declares outputs like `public_subnet_id` and `private_subnet_id`
2. Root `main.tf` passes these outputs to the compute module: `public_subnet_id = module.networking.public_subnet_id`
3. `compute/variables.tf` declares the input variable and `compute/ec2.tf` uses it via `var.public_subnet_id`

**Important:** Modules are separate scopes. You cannot reference resources from the networking module directly inside compute; values must be passed through outputs/inputs.

### Networking Module (./networking)

- VPC with CIDR 10.0.0.0/16
- Public subnet: 10.0.1.0/24 (us-west-2a) with public IP assignment enabled
- Private subnet: 10.0.100.0/24 (us-west-2a) with no public IPs
- Internet gateway for public subnet connectivity
- Separate route tables for public (with IGW route) and private subnets
- Route table associations connect subnets to their respective tables

### Compute Module (./compute)

- EC2 instance: Ubuntu Server 22.04 LTS (m5.2xlarge) in the public subnet
- EKS resources (eks.tf exists but appears minimal/empty)
- Requires `public_subnet_id` input variable from networking module

## Common Terraform Commands

```bash
# Initialize Terraform and download providers
terraform init

# Validate configuration
terraform validate

# Format all .tf files
terraform fmt -recursive

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

## Resource Naming Convention

All resources use the prefix `kellyebler-` and include a special tag:
```hcl
tags = {
  please_keep_my_resources = "true"
}
```

This tag prevents accidental deletion of resources.

## Variables and Credentials

Root `variables.tf` defines sensitive variables:
- `aws_access_key` / `aws_secret_key` - AWS credentials
- `datadog_api_key` / `datadog_app_key` - Datadog credentials (referenced but not used in this module)

These should be set via Terraform Cloud workspace variables or environment variables, not hardcoded.

## Related Infrastructure

A sibling directory `../datadog/` contains Datadog-specific Terraform configuration using the DataDog/datadog provider, configured with its own Terraform Cloud workspace named "datadog". It includes Synthetics test examples.
