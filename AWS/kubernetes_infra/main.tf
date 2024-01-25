### All providers for modules should be configured here

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

locals {
  dns_zone_name            = "${var.environment}.${var.domain_primary_zone.domain}"
  certmanager_issuer_email = "admin@${var.domain_primary_zone.domain}"
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

### Kubernetes ###
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
  kubeconfig_path  = var.kubeconfig_path
}

### Gitlab ###
locals {
  gitlab_chart_values = {
    ## Mandatory params
    "certmanager-issuer.email"            = local.certmanager_issuer_email
    "global.hosts.domain"                 = "gitlab.${local.dns_zone_name}"
    "global.ingress.enabled"              = true
    "global.ingress.configureCertmanager" = true
    "global.edition"                      = var.gitlab_edition
    ## additional parametrs
    # "global.railsSecrets.secret"                = "gitlab-rails-secret"
    # "gitlab.gitaly.persistence.matchLabels.app" = "gitaly"
    # "postgresql.persistence.existingClaim"      = "data-gitlab-postgresql-0"
    # "global.psql.password.secret"               = "gitlab-postgresql-password"
    # "global.psql.password.key"                  = "postgresql-password"
  }
}

module "gitlab" {
  source = "./modules/gitlab"
  depends_on = [
    module.kubernetes,
    module.local_kube_config
  ]

  # variables to be sent in kubernetes module
  dns_zone_name        = local.dns_zone_name
  gitlab_chart_version = var.gitlab_chart_version
  gitlab_chart_values  = local.gitlab_chart_values
}
