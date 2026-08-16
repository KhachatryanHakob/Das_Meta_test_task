output "vpc_id" {
  description = "ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets used by EKS worker nodes."
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "IDs of the public subnets used for internet-facing load balancers."
  value       = module.vpc.public_subnets
}

output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

output "configure_kubectl" {
  description = "AWS CLI command to configure kubectl for the EKS cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "application_url" {
  description = "Public application URL."
  value       = "http://${data.aws_lb.application.dns_name}"
}

output "route53_health_check_id" {
  description = "Route53 external health check ID."
  value       = aws_route53_health_check.application.id
}