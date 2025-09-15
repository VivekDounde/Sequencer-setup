module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr
  azs  = var.public_azs

  public_subnets  = ["10.0.0.0/24","10.0.1.0/24","10.0.2.0/24"]
  private_subnets = ["10.0.16.0/20","10.0.32.0/20","10.0.48.0/20"]

  enable_nat_gateway = true
  single_nat_gateway = false
}
