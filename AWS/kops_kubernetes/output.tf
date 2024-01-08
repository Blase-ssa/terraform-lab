output "kops_bucket_id" {
  description = "S3 bucket ID for storing kOps states"
  value       = aws_s3_bucket.kops-state.id
}
output "kops_bucket_arn" {
  description = "S3 bucket ID for storing kOps states"
  value       = aws_s3_bucket.kops-state.arn
}
output "kops_bucket_domain_name" {
  description = "S3 bucket ID for storing kOps states"
  value       = aws_s3_bucket.kops-state.bucket_domain_name
}