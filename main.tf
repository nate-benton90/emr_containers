// Terraform & provider configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.44.0"
    }
  }
  required_version = ">= 0.14.9"
}

# NOTE: user must ajust the profile value according to whatever they configured for the AWS CLI on 
# their local machine
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

// Modules
module "vpc" {
  source = "./infra/vpc"
}

module "s3" {
  source = "./infra/s3"
}

# TODO: add variables to standardize and mask values for region and especially AWS account ID
module "iam" {
  source = "./iam"
  region = "us-east-1"
  account_id = "640048293282"
  eks_cluster_name = module.eks.eks_cluster_name
  kubernetes_namespace = module.eks.kubernetes_namespace
}

module ecr {
  source = "./infra/ecr"
}

# TODO: add global variables for multiple instances of hard-coded values below/above
module "image_mgmt" {
  source = "./images"
  region = "us-east-1"
  account_id = "640048293282"
  repository_url = module.ecr.emr_eks_repository_url
}

module "lambda" {
  source = "./infra/lambda"
  lambda_execution_role_name = module.iam.start_job_lambda_role
}

module "eks" {
  source = "./infra/eks"
  role_arn = module.iam.eks_cluster_role
  node_role_arn = module.iam.eks_node_role
  eks_vpc_id = module.vpc.eks_vpc_id
  eks_subnet_ids = module.vpc.eks_subnet_ids
}

module "emr_virtual_cluster" {
  source            = "./infra/emr"
  eks_cluster_name  = module.eks.eks_cluster_name
  emr_eks_id_mapping = module.iam.emr_eks_id_mapping
  node_group_name = module.eks.node_group_name
}
