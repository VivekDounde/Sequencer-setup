output "cluster_name" {
  value = module.eks.cluster_id
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_id} --region ${var.aws_region}"
}

output "redis_primary_endpoint" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}

# Expose EKS OIDC provider ARN and URL for IRSA usage
output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}
