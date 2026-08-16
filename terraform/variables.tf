variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
  default     = "eu-central-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "devops-platform-test"
}

variable "environment" {
  description = "Environment name used for tagging."
  type        = string
  default     = "test"
}

variable "kubernetes_version" {
  description = "Kubernetes version used by the EKS cluster."
  type        = string
  default     = "1.36"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "node_instance_type" {
  description = "EC2 instance type used by the EKS managed node group."
  type        = string
  default     = "t3.medium"
}

variable "desired_nodes" {
  description = "Desired number of worker nodes in the EKS managed node group."
  type        = number
  default     = 2
}

variable "grafana_slack_webhook_url" {
  description = "Slack webhook URL used by Grafana alerting."
  type        = string
  sensitive   = true
}