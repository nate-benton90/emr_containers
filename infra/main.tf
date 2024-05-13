terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

module "vpc" {
  source = "./vpc"
  // Pass variables here
}

module "s3" {
  source = "./s3"
  // Pass variables here
}


