// EKS IAM config
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

output "eks_role" {
  description = "The IAM role for EKS"
  value       = aws_iam_role.eks_cluster_role.arn
}

// Node group IAM config
resource "aws_iam_role" "eks_node_role" {
  name = "eks_node_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_role_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_instance_profile" "eks_node_instance_profile" {
  name = "eks_node_instance_profile"
  role = aws_iam_role.eks_node_role.name
}

output "eks_node_role" {
  description = "The IAM role for EKS node group"
  value       = aws_iam_role.eks_node_role.arn
}

output "eks_node_instance_profile" {
  description = "The IAM instance profile for EKS node group"
  value       = aws_iam_instance_profile.eks_node_instance_profile.arn
}