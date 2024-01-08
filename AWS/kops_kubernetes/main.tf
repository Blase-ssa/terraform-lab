provider "aws" {
  region = var.aws_region
}

locals {
  kops_env_sh = "./scripts/kops_env.sh"
}

resource "aws_s3_bucket" "kops-state" {
  bucket_prefix = "kops-state-${var.environment}-"
  force_destroy = true

  tags = {
    name        = "kops-state"
    environment = var.environment
  }
}

#│ Destroy-time provisioners and their connection configurations may only reference attributes of the related resource, via 'self', 'count.index', or 'each.key'.
#│ References to other resources during the destroy phase can cause dependency cycles and interact poorly with create_before_destroy.
# Thus, to use variables in a script, you need to save them to a file. ("kops_env" step)

resource "null_resource" "kops_destroy" {
  provisioner "local-exec" {
    when        = destroy
    command     = <<SCRIPTEND
      if [ -f ./scripts/kops_env.sh ]; then
        source ./scripts/kops_env.sh
      else
        echo "Skip task reason: Environment file (./scripts/kops_env.sh) does not exists"
        exit 0
      fi
      kops delete cluster \
        --region=$REGION \
        --name=$CLUSTER_NAME \
        --yes
    SCRIPTEND
    interpreter = ["bash", "-c"]
  }
}

# resource "aws_s3_bucket_object" "kops-folder" {
#     bucket  = "${aws_s3_bucket.kops-state.id}"
#     acl     = "private"
#     key     =  "kops_dev/config/"
#     content_type = "application/x-directory"
# }

resource "local_file" "kops_env" {
  filename = "${local.kops_env_sh}"
  content  = <<EOF
export REGION=${var.aws_region}
export AWS_REGION=${var.aws_region}
export CLUSTER_NAME=${var.kubernetes_domain_prefix}_${var.environment}
export KOPS_STATE_STORE='s3://${aws_s3_bucket.kops-state.id}'
export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
EOF
}

resource "null_resource" "kops_create" {
  provisioner "local-exec" {
    when        = create
    command     = <<SCRIPTEND
    source  ${local.kops_env_sh}
    kops create cluster \
      --cloud aws \
      --zones=$REGION \
      --name=${var.kubernetes_domain_prefix}_${var.environment} \
      --state=s3://${aws_s3_bucket.kops-state.id} \
      --node-count=${var.kubernetes_node_count} \
      --node-size=${var.kubernetes_node_type} \
      --control-plane-size strings=${var.kubernetes_node_type} \
      --dns-zone=${var.kubernetes_domain_prefix}.${var.environment}.${var.domain_primary_zone.domain} \
      --yes
    SCRIPTEND
    interpreter = ["bash", "-c"]
    on_failure  = fail
  }
  depends_on = [aws_s3_bucket.kops-state, local_file.kops_env]
}
