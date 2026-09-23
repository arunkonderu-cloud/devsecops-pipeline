output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_issuer_url" {
  description = "Use to create an IAM OIDC provider for IRSA."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "kms_key_arn" {
  value = aws_kms_key.eks.arn
}

output "node_role_arn" {
  value = aws_iam_role.node.arn
}
