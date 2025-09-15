module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 18.0.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"   # pick supported EKS version for your environment
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    ondemand = {
      desired_capacity = var.ondemand_node_count
      min_capacity     = var.ondemand_node_count
      max_capacity     = var.ondemand_node_count + 2
      instance_types   = [var.ondemand_instance_type]
      additional_tags  = { role = "stateful" }
      disk_size        = 200
      labels = {
        role = "stateful"
      }
    }

    spot = {
      desired_capacity = var.spot_node_count
      min_capacity     = 0
      max_capacity     = 10
      instance_types   = var.spot_instance_types
      capacity_type    = "SPOT"
      labels = {
        role = "stateless"
      }
      taints = [
        { key = "spot", value = "true", effect = "NO_SCHEDULE" }
      ]
    }
  }

  manage_aws_auth = true
  enable_irsa     = true   # creates OIDC provider and enables IRSA
}
