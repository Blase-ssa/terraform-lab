# output "kops_bucket_id" {
#   description = "S3 bucket ID for storing kOps states"
#   value       = aws_s3_bucket.kops-state.id
# }

# output "cluster_info" {
#   value = module.kubernetes.aws_eks_cluster.kubernetes
# }

# output "endpoint" {
#   value = module.kubernetes.aws_eks_cluster.kubernetes.endpoint
# }

# output "kubeconfig-certificate-authority-data" {
#   value = module.kubernetes.aws_eks_cluster.kubernetes.certificate_authority[0].data
# }

output "aws_eks_cluster" {
  description = "AWS Kubernetes cluster initial info"
  value = {
    name   = "${var.kubernetes_domain_prefix}-${var.environment}"
    region = var.aws_region
  }
}
