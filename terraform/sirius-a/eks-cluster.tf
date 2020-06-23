data "aws_eks_cluster" "cluster" {
  name  = module.sirius-a.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name  = module.sirius-a.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "sirius-a" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.16"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    app = {
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
