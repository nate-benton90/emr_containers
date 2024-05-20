# in infra/eks/variables.tf
variable "role_arn" {
  description = "The ARN of the IAM role to use for EKS"
  type        = string
}

resource "aws_eks_cluster" "foo-emr-eks-cluster" {
  name     = "foo-emr-eks-cluster"
  role_arn = var.role_arn
  vpc_config {
    subnet_ids = aws_subnet.eks_subnet[*].id
  }
}

resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
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
