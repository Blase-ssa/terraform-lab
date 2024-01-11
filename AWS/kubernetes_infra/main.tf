provider "aws" {
  region = var.aws_region
}

# S3 bucket
# resource "aws_s3_bucket" "kops-state" {
#   bucket_prefix = "kops-state-${var.environment}-"
#   force_destroy = true

#   tags = {
#     name        = "kops-state"
#     environment = var.environment
#   }
# }

module "kubernetes" {
  source = "./modules/kubernetes"

  # variables to be sent in kubernetes module
  aws_region          = var.aws_region
  environment         = var.environment
  domain_primary_zone = var.domain_primary_zone
  aws_cluster_name    = "${var.kubernetes_domain_prefix}-${var.environment}"
  vpc_id              = var.vpc_id
}

module "local_kube_config" {
  source     = "./other/load_kubernetes_config"
  depends_on = [module.kubernetes]

  # variables to be sent in kubernetes module
  aws_region       = var.aws_region
  aws_cluster_name = "${var.kubernetes_domain_prefix}-${var.environment}"
}

# module "gitlab" {
#   source = "./modules/gitlab"
#   depends_on = [ module.kubernetes ]

#   # variables to be sent in kubernetes module
#   # aws_region               = var.aws_region
#   # environment              = var.environment
#   # domain_primary_zone      = var.domain_primary_zone

# }

