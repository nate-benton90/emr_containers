// Variables for cluster creation
variable "eks_vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "eks_subnet_ids" {
  description = "The IDs of the subnets"
  type        = list(string)
}

variable "role_arn" {
  description = "The ARN of the IAM role to use for EKS"
  type        = string
}

variable "node_role_arn" {
  description = "The ARN of the IAM role to use for EKS node group"
  type        = string
}

// Cluster provisioning/config
resource "aws_eks_cluster" "foo-emr-eks-cluster" {
  name     = "foo-emr-eks-cluster"
  role_arn = var.role_arn
  vpc_config {
    subnet_ids = var.eks_subnet_ids
  }
}

// Create EC2 node group for EKS
resource "aws_eks_node_group" "emr-eks-node-group-foo" {
  depends_on = [aws_eks_cluster.foo-emr-eks-cluster]
  cluster_name    = aws_eks_cluster.foo-emr-eks-cluster.name
  node_group_name = "emr-eks-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.eks_subnet_ids
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  instance_types = ["t3.micro"]
  capacity_type = "SPOT"
  labels = {
    usage = "test-cluster"
  }
}
