# data "terraform_remote_state" "root_state" {
#     # access to root terraform state variables
#     backend = "local"
#     config = {
#       path = "../../terraform.tfstate"
#     }
# }

### configure network
data "aws_vpc" "main_cidr" {
  ## get existing network data
  id = var.vpc_id
}

resource "aws_subnet" "kubernetes_a" {
  vpc_id            = data.aws_vpc.main_cidr.id
  availability_zone = "${var.aws_region}a"
  cidr_block        = cidrsubnet(data.aws_vpc.main_cidr.cidr_block, var.subnet_newbits, 0)
  ## if main cidr block = "172.31.0.0/16" and newbits = 8, then:
  ##   16 + 8 = 24 bit network
  ##   Network:      172.31.0.0/24
  ##   HostMin:      172.31.0.1
  ##   HostMax:      172.31.0.254
  ##   Hosts total:  254
}

resource "aws_subnet" "kubernetes_b" {
  vpc_id            = aws_subnet.kubernetes_a.vpc_id # to make sure that same ID is used
  availability_zone = "${var.aws_region}b"
  cidr_block        = cidrsubnet(data.aws_vpc.main_cidr.cidr_block, var.subnet_newbits, 1)
}

resource "aws_subnet" "kubernetes_c" {
  vpc_id            = aws_subnet.kubernetes_a.vpc_id # to make sure that same ID is used
  availability_zone = "${var.aws_region}c"
  cidr_block        = cidrsubnet(data.aws_vpc.main_cidr.cidr_block, var.subnet_newbits, 2)
}

### IAM
resource "aws_iam_role" "kubernetes" {
  description = <<EOT
  Amazon EKS - Cluster role.
  The Amazon EKS cluster IAM role is required for each cluster. 
  Kubernetes clusters managed by Amazon EKS use this role to manage 
  nodes and the legacy Cloud Provider uses this role to create load 
  balancers with Elastic Load Balancing for services.

  Before you can create Amazon EKS clusters, you must create an IAM 
  role with either of the following IAM policies: 
  1. AmazonEKSClusterPolicy
  2. AmazonEKSVPCResourceController
  EOT
  name        = "eksClusterRole-${var.environment}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  tags = {
    aws_iam_role = "eksClusterRole-${var.environment}"
  }
}

resource "aws_iam_role_policy_attachment" "kubernetes-AmazonEKSClusterPolicy" {
  role       = aws_iam_role.kubernetes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

## Optionally, enable Security Groups for Pods
## Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "kubernetes-AmazonEKSVPCResourceController" {
  role       = aws_iam_role.kubernetes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

### Create kubernetes cluster
resource "aws_eks_cluster" "kubernetes" {
  name     = var.aws_cluster_name
  role_arn = aws_iam_role.kubernetes.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.kubernetes_a.id,
      aws_subnet.kubernetes_b.id,
      #aws_subnet.kubernetes_c.id,
    ]
  }

  ## Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  ## Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.kubernetes-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.kubernetes-AmazonEKSVPCResourceController,
  ]
}

# resource "aws_route53_record" "kubernetes" {
#   ## configure DNS records
#   zone_id = var.domain_primary_zone.id
#   name    = "${var.kubernetes_domain_prefix}.${var.environment}.${var.domain_primary_zone.domain}"
#   type    = "A"
#   ttl     = 300
#   # records = [aws_eip.lb.public_ip]
#   records = [aws_eks_cluster.kubernetes.endpoint]
# }


resource "local_file" "cluster_info" {
  filename = "cluster_info.json"
  content  = jsonencode(aws_eks_cluster.kubernetes)
}



