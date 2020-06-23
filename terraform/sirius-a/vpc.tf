provider "aws" {
  version = ">= 2.66.0"
  region  = var.region
}

terraform {
  backend "s3" {
    bucket = "jupiter"
    key    = "cluster/sirius-a"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "sirius-b" {
  backend = "s3"
  config  = {
    bucket = "jupiter"
    key    = "cluster/sirius-b"
    region = "us-east-1"
  }
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "sirius-a-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "sirius-a-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names 
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]

  enable_nat_gateway   = true
  enable_vpn_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    Terraform                                     = "true"
    Environment                                   = "testing"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

resource "aws_vpc_peering_connection" "sirius-peering" {
  peer_vpc_id = data.terraform_remote_state.sirius-b.outputs.vpc_id
  vpc_id      = module.vpc.vpc_id
}
