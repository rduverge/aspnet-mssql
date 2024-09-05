module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.30"


  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns = {
      resolve_conflict = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflict = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflict = "OVERWRITE"
    }
  }


  eks_managed_node_groups = {
    node-group = {
      desired_size   = 1
      min_size       = 1
      max_size       = 2
      instance_types = ["t2.micro"]

      tags = {
        Environment = "test"
        Terraform   = "true"
      }
    }
  }

  tags = {
    Environment = "test"
    Terraform   = "true"
  }
}

