# OpenTelemetry Instrumented Sample Application

A simple Flask application instrumented with OpenTelemetry SDK that sends traces to Datadog via OTLP.

## Features

- OpenTelemetry auto-instrumentation for Flask
- Manual span creation with custom attributes
- Multiple endpoints demonstrating different tracing patterns
- OTLP gRPC exporter sending traces to Datadog agent sidecar

## Endpoints

- `GET /` - Simple hello world
- `GET /api/users` - Returns list of users with custom span attributes
- `GET /api/process` - Demonstrates nested spans
- `GET /health` - Health check endpoint

## Build and Deploy

### 1. Build the Docker image

You'll need to push this to a container registry accessible by your EKS cluster (like ECR):

```bash
cd ~/proag_fargate/sample-app

# Build the image
docker build -t sample-otel-app:latest .

# Tag for ECR (replace with your account ID and region)
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-west-2.amazonaws.com

# Create ECR repository if it doesn't exist
aws ecr create-repository --repository-name sample-otel-app --region us-west-2

# Tag and push
docker tag sample-otel-app:latest <account-id>.dkr.ecr.us-west-2.amazonaws.com/sample-otel-app:latest
docker push <account-id>.dkr.ecr.us-west-2.amazonaws.com/sample-otel-app:latest
```

### 2. Update deployment.yaml

Replace `<your-ecr-repo>` in `deployment.yaml` with your actual ECR repository URL.

### 3. Create Fargate profile for sample-app namespace

You need to add a Fargate profile for the `sample-app` namespace:

Add this to your `compute/eks.tf`:

```hcl
resource "aws_eks_fargate_profile" "sample_app" {
  cluster_name           = aws_eks_cluster.kellyebler_cluster.name
  fargate_profile_name   = "kellyebler-fargate-sample-app"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_execution_role.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "sample-app"
  }

  tags = {
    Name                     = "kellyebler-fargate-sample-app"
    please_keep_my_resources = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_fargate_pod_execution_policy
  ]
}
```

Then run:
```bash
terraform apply
```

### 4. Create the datadog-secret in the sample-app namespace

```bash
kubectl create secret generic datadog-secret \
  --from-literal=api-key=<your-datadog-api-key> \
  -n sample-app
```

### 5. Deploy the application

```bash
kubectl apply -f deployment.yaml
```

### 6. Verify deployment

```bash
# Check pods are running
kubectl get pods -n sample-app

# Check logs
kubectl logs -n sample-app -l app=sample-otel-app -c app

# Check Datadog agent logs
kubectl logs -n sample-app -l app=sample-otel-app -c datadog-agent
```

### 7. Test the application

```bash
# Port forward to access the app
kubectl port-forward -n sample-app service/sample-otel-app 8080:80

# In another terminal, generate some traffic
curl http://localhost:8080/
curl http://localhost:8080/api/users
curl http://localhost:8080/api/process
```

## How It Works

1. **OpenTelemetry SDK** in the Flask app creates traces and spans
2. **OTLP Exporter** sends traces via gRPC to `localhost:4317` (the Datadog agent sidecar)
3. **Datadog Agent** receives OTLP traces and forwards them to Datadog
4. **Traces appear in Datadog APM** with service name `sample-otel-app`

## Key Configuration

- `OTEL_EXPORTER_OTLP_ENDPOINT`: Points to Datadog agent sidecar (localhost:4317)
- `DD_OTLP_CONFIG_RECEIVER_PROTOCOLS_GRPC_ENDPOINT`: Datadog agent listens on port 4317 for OTLP
- Unified service tagging with `tags.datadoghq.com/*` labels
