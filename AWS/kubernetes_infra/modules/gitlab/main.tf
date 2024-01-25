## Provider, can not be used in module as I need to use "depends_on" in root module.
# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config"
#   }
# }

resource "kubernetes_namespace" "gitlab" {
  metadata {
    name = "gitlab"
  }
}

resource "helm_release" "gitlab" {
  depends_on = [kubernetes_namespace.gitlab]
  name       = "gitlab"
  repository = "https://charts.gitlab.io/"
  chart      = "gitlab"
  version    = var.gitlab_chart_version
  namespace  = "gitlab"
  timeout    = 2500

  dynamic "set" {
    for_each = var.gitlab_chart_values
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "kubernetes_ingress" "gitlab" {
  depends_on = [helm_release.gitlab]
  metadata {
    name = "gitlab"
  }
  spec {
    backend {
      service_name = "gitlab-webservice-default"
      service_port = 443
    }
  }
}