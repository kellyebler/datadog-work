# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "kellyebler-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name                     = "kellyebler-eks-cluster-role"
    please_keep_my_resources = "true"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS Fargate Pod Execution IAM Role
resource "aws_iam_role" "eks_fargate_pod_execution_role" {
  name = "kellyebler-eks-fargate-pod-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
  })

  tags = {
    Name                     = "kellyebler-eks-fargate-pod-execution-role"
    please_keep_my_resources = "true"
  }
}

resource "aws_iam_role_policy_attachment" "eks_fargate_pod_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_pod_execution_role.name
}

# EKS Cluster
resource "aws_eks_cluster" "kellyebler_cluster" {
  name     = "kellyebler-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.31"

  vpc_config {
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  tags = {
    Name                     = "kellyebler-eks-cluster"
    please_keep_my_resources = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller
  ]
}

# Fargate Profile for default namespace
resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.kellyebler_cluster.name
  fargate_profile_name   = "kellyebler-fargate-default"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_execution_role.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "default"
  }

  tags = {
    Name                     = "kellyebler-fargate-default"
    please_keep_my_resources = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_fargate_pod_execution_policy
  ]
}

# Fargate Profile for kube-system namespace
resource "aws_eks_fargate_profile" "kube_system" {
  cluster_name           = aws_eks_cluster.kellyebler_cluster.name
  fargate_profile_name   = "kellyebler-fargate-kube-system"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_execution_role.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "kube-system"
  }

  tags = {
    Name                     = "kellyebler-fargate-kube-system"
    please_keep_my_resources = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_fargate_pod_execution_policy
  ]
}

# Fargate Profile for datadog-agent namespace
resource "aws_eks_fargate_profile" "datadog_agent" {
  cluster_name           = aws_eks_cluster.kellyebler_cluster.name
  fargate_profile_name   = "kellyebler-fargate-datadog-agent"
  pod_execution_role_arn = aws_iam_role.eks_fargate_pod_execution_role.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "datadog-agent"
  }

  tags = {
    Name                     = "kellyebler-fargate-datadog-agent"
    please_keep_my_resources = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_fargate_pod_execution_policy
  ]
}

# Fargate Profile for sample-app namespace
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

# Outputs
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.kellyebler_cluster.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.kellyebler_cluster.name
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.kellyebler_cluster.vpc_config[0].cluster_security_group_id
}

output "fargate_profile_default_id" {
  description = "Fargate profile ID for default namespace"
  value       = aws_eks_fargate_profile.default.id
}

output "fargate_profile_kube_system_id" {
  description = "Fargate profile ID for kube-system namespace"
  value       = aws_eks_fargate_profile.kube_system.id
}

output "fargate_profile_datadog_agent_id" {
  description = "Fargate profile ID for datadog-agent namespace"
  value       = aws_eks_fargate_profile.datadog_agent.id
}

output "fargate_profile_sample_app_id" {
  description = "Fargate profile ID for sample-app namespace"
  value       = aws_eks_fargate_profile.sample_app.id
}
