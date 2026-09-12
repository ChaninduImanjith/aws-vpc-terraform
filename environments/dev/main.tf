module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_subnet_cidrs     = var.private_subnet_cidrs
  enable_single_nat_gateway = var.enable_single_nat_gateway
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = "dev-eks-cluster"
  cluster_version = "1.30"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids

  desired_size   = 2
  min_size       = 1
  max_size       = 3
  instance_types = ["t3.medium"]

  tags = {
    Environment = "dev"
    Project     = "DevOps-Portfolio"
    ManagedBy   = "Terraform"
  }
}
