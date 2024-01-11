output "endpoint" {
  value = aws_eks_cluster.kubernetes.endpoint
}

output "kubernetes_id" {
  value = aws_eks_cluster.kubernetes.id
}
