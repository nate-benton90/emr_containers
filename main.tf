terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.44.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

module "vpc" {
  source = "./infra/vpc"
  // Pass variables here
}

module "s3" {
  source = "./infra/s3"
  // Pass variables here
}

module "iam" {
  source = "./iam"
  // Pass variables here
}

module "eks" {
  source = "./infra/eks"
  role_arn = module.iam.eks_role
  // Pass variables here
}

# module "emr_eks" {
#   source = "./emr"
#   // Pass variables here
# }

