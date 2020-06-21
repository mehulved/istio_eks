data "aws_eks_cluster" "cluster" {
  count = var.cluster_count
  name  = module.istio-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.cluster_count
  name  = module.istio-cluster.cluster_id
}

provider "kubernetes" {
  host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, list("")), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, list("")), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, list("")), 0)
  load_config_file       = false
  version                = "~> 1.9"
}

module "istio-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.16"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    nginx = {
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1

      instance_size = "t2.small"

      k8s_labels = {
        Environment = "testing"
      }
    }
  }

  tags = {
    Environment = "testing"
  }
}
