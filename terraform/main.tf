provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "personal"
  region                  = var.region
}

// https://www.terraform.io/docs/language/settings/backends/s3.html
terraform {
  required_version = "~>1.0.0" # allow new patch releases within a specific minor release
  backend "s3" {
    bucket = "aws-demo-infrastructure"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}

module "network" {
  source             = "./network"
  vpc_name           = var.vpc_name
  eks_cluster_name   = var.eks_cluster_name
  cidr               = var.cidr
  availability_zones = var.availability_zones
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  environment        = var.environment
}

module "eks_cluster" {
  source              = "./eks/eks_cluster"
  cluster_name        = var.eks_cluster_name
  public_subnets      = module.network.public_subnets
  private_subnets     = module.network.private_subnets
  environment         = var.environment
  eks_cluster_version = var.eks_cluster_version
}

module "eks_node_group" {
  source           = "./eks/eks_node_group"
  eks_cluster_name = module.eks_cluster.cluster_name
  node_group_name  = var.node_group_name
  subnet_ids       = module.network.private_subnets.*.id
  instance_types   = var.ng_instance_types
  disk_size        = var.disk_size
  desired_nodes    = var.desired_nodes
  max_nodes        = var.max_nodes
  min_nodes        = var.min_nodes
  environment      = var.environment
}

module "fargate" {
  source               = "./eks/fargate"
  eks_cluster_name     = module.eks_cluster.cluster_name
  fargate_profile_name = var.fargate_profile_name
  subnet_ids           = module.network.private_subnets.*.id
  fargate_namespaces   = var.fargate_namespaces
  environment          = var.environment
}

module "kubernetes" {
  source               = "./kubernetes"
  region               = var.region
  vpc_id               = module.network.vpc_id
  cidr                 = var.cidr
  efs_subnet_ids       = module.network.private_subnets.*.id
  eks_cluster_name     = module.eks_cluster.cluster_name
  eks_cluster_endpoint = module.eks_cluster.endpoint
  eks_oidc_url         = module.eks_cluster.oidc_url
  eks_ca_certificate   = module.eks_cluster.ca_certificate
  fargate_namespaces   = var.fargate_namespaces
  environment          = var.environment
}
