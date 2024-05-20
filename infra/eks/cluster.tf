// Variables for cluster creation
variable "role_arn" {
  description = "The ARN of the IAM role to use for EKS"
  type        = string
}

variable "eks_vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "eks_subnet_ids" {
  description = "The IDs of the subnets"
  type        = list(string)
}


// Create EC2 node group for EKS
resource "aws_eks_node_group" "emr-eks-node-group-foo" {
  cluster_name    = "foo-emr-eks-cluster-node-group"
  node_group_name = "example-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.eks_subnet[*].id
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


// Cluster provisioning/config
resource "aws_eks_cluster" "foo-emr-eks-cluster" {
  name     = "foo-emr-eks-cluster"
  role_arn = var.role_arn
  vpc_config {
    subnet_ids = var.eks_subnet_ids
  }
}
