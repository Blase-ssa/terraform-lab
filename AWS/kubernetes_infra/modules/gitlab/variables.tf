variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
  validation {
    condition     = can(regex("dev", var.environment)) || can(regex("test", var.environment)) || can(regex("prod", var.environment))
    error_message = "Environment should be \"dev\", \"test\", \"prod\" or contain \"dev\", \"test\", \"prod\" as a part of name"
  }
}

variable "domain_primary_zone" {
  description = "Domain you own."
  type        = map(string)
  default = {
    domain = "blase-infra.click"
    id     = "Z101155419KLTASVLU3J"
  }
}

variable "dns_zone_name" {
  default = "blase-infra.click"
}

variable "gitlab_chart_version" {
  default = "7.6.1"
}

variable "gitlab_chart_values" {
  default = {
    # Mandatory params
    "certmanager-issuer.email"            = "admin@blase-infra.click"
    "global.hosts.domain"                 = "gitlab.blase-infra.click"
    "global.ingress.enabled"              = true
    "global.ingress.configureCertmanager" = true
    "global.edition"                      = "ee"
  }
}
