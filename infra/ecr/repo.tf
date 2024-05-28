// Resources
resource "aws_ecr_repository" "emr-eks-repository" {
  name = "foo-emr-eks-spark-image"
}

// Outputs
output "emr_eks_repository_url" {
  description = "The ECR repository for EMR on EKS"
  value       = aws_ecr_repository.emr-eks-repository.repository_url
}
