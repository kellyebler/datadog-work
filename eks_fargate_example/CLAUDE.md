# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This directory contains a demonstration of EKS Fargate with Datadog APM using OpenTelemetry (OTLP). The setup showcases how to send traces from a Flask application instrumented with OpenTelemetry SDK to Datadog via OTLP protocol in an EKS Fargate environment.

The infrastructure is managed by Terraform in the parent `../terraform/aws/` directory, which provisions:
- VPC with public/private subnets across multiple availability zones
- EKS cluster (v1.31) named `kellyebler-eks-cluster`
- Fargate profiles for namespaces: `default`, `kube-system`, `datadog-agent`, and `sample-app`

## Architecture

### Tracing Flow

1. **Flask Application** (`sample-app/app.py`) creates traces using OpenTelemetry SDK
2. **OTLP Exporter** sends traces via gRPC to `localhost:4317` (Datadog agent sidecar)
3. **Datadog Agent Sidecar** receives OTLP traces on port 4317 and forwards to Datadog backend
4. **Traces appear in Datadog APM** with service name `sample-otel-app`

### EKS Fargate Setup

The deployment uses a **manual sidecar pattern** (`deployment.yaml`) rather than admission controller injection because Fargate has specific requirements. Each pod contains:
- Application container with OpenTelemetry instrumentation
- Datadog agent sidecar configured for OTLP reception and Fargate mode
- Shared `emptyDir` volume at `/var/run/datadog` for inter-container communication
- `shareProcessNamespace: true` for process visibility

### Datadog Operator Configuration

`datadog_agent.yaml` defines the DatadogAgent custom resource which configures:
- Orchestrator Explorer for Kubernetes resource monitoring
- Admission controller with sidecar injection enabled (provider: fargate)
- OTLP receiver on ports 4317 (gRPC) and 4318 (HTTP)
- Default sidecar profile with Fargate-specific environment variables

### RBAC

`cluster_role.yaml` and `cluster_role_binding.yaml` grant the Datadog agent permissions to read Kubernetes resources (pods, nodes, deployments, services, etc.) for autodiscovery and orchestrator explorer features.

## Common Commands

### EKS Cluster Access

```bash
# Update kubeconfig to access the cluster
aws eks update-kubeconfig --region us-west-2 --name kellyebler-eks-cluster

# Verify cluster connectivity
kubectl cluster-info
kubectl get nodes
```

### Sample Application Deployment

```bash
# Navigate to sample app directory
cd sample-app

# Build and push Docker image (requires AWS ECR access)
./build-and-push.sh

# Create the datadog-secret in sample-app namespace
kubectl create namespace sample-app
kubectl create secret generic datadog-secret \
  --from-literal=api-key=<your-datadog-api-key> \
  -n sample-app

# Deploy the application
kubectl apply -f deployment.yaml

# Verify deployment
kubectl get pods -n sample-app
kubectl logs -n sample-app -l app=sample-otel-app -c app
kubectl logs -n sample-app -l app=sample-otel-app -c datadog-agent
```

### Testing the Application

```bash
# Port forward to access the app locally
kubectl port-forward -n sample-app service/sample-otel-app 8080:80

# In another terminal, generate traffic
./test-app.sh
# Or manually:
curl http://localhost:8080/
curl http://localhost:8080/api/users
curl http://localhost:8080/api/process
curl http://localhost:8080/health
```

### Datadog Agent Setup

```bash
# Install Datadog Operator (if not already installed)
helm repo add datadog https://helm.datadoghq.com
helm repo update
kubectl create namespace datadog-agent

# Create datadog-secret in datadog-agent namespace
kubectl create secret generic datadog-secret \
  --from-literal=api-key=<your-datadog-api-key> \
  --from-literal=token=<random-32-char-token> \
  -n datadog-agent

# Install the operator
helm install datadog-operator datadog/datadog-operator -n datadog-agent

# Apply RBAC and DatadogAgent CR
kubectl apply -f cluster_role.yaml
kubectl apply -f cluster_role_binding.yaml
kubectl apply -f datadog_agent.yaml -n datadog-agent
```

## Key Configuration Details

### Unified Service Tagging

Both application and Datadog agent use consistent tagging via pod labels:
```yaml
labels:
  tags.datadoghq.com/env: "production"
  tags.datadoghq.com/service: "sample-otel-app"
  tags.datadoghq.com/version: "1.0.0"
```

These labels are mapped to environment variables using `fieldRef` and ensure proper correlation between APM traces and infrastructure metrics.

### OTLP Configuration

The Datadog agent sidecar must be configured with:
- `DD_OTLP_CONFIG_RECEIVER_PROTOCOLS_GRPC_ENDPOINT: "0.0.0.0:4317"`
- `DD_OTLP_CONFIG_RECEIVER_PROTOCOLS_HTTP_ENDPOINT: "0.0.0.0:4318"`
- `DD_EKS_FARGATE: "true"`
- `DD_CLUSTER_NAME: "kellyebler-eks-cluster"`

The application's OTLP exporter points to `http://localhost:4317` to reach the sidecar.

### Fargate-Specific Requirements

- Fargate profiles must exist for each namespace before pods can be scheduled
- Pods must run in private subnets (configured in Terraform: `subnet_ids = var.private_subnet_ids`)
- NAT gateway is required for outbound internet access from private subnets
- Process namespace sharing (`shareProcessNamespace: true`) enables the agent to see application processes

## Terraform Infrastructure

The infrastructure lives in `../terraform/aws/`:
- **Networking module** (`networking/`): VPC, subnets (2 public, 2 private across us-west-2a/2b), internet gateway, NAT gateway, route tables
- **Compute module** (`compute/`): EKS cluster, IAM roles, Fargate profiles for multiple namespaces, EC2 instance
- Uses Terraform Cloud with organization `kellyebler183451b6` and workspace `datadog-work`

To modify infrastructure:
```bash
cd ../terraform/aws
terraform init
terraform plan
terraform apply
```

## Application Endpoints

- `GET /` - Hello world with custom span attribute
- `GET /api/users` - Returns user list, demonstrates span attributes
- `GET /api/process` - Shows nested spans (fetch → transform → save)
- `GET /health` - Health check endpoint (used by liveness/readiness probes)

## Deployment Variations

Two deployment options are available:
- `deployment.yaml` - Current approach with manual Datadog agent sidecar
- `deployment_manual_sidecar.yaml` - Alternative configuration (if exploring different patterns)

The manual sidecar approach is necessary because the admission controller injection has Fargate-specific configuration requirements that are more reliably met with explicit container definitions.
