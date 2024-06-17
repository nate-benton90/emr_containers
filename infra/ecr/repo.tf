// Resources
resource "aws_ecr_repository" "emr-eks-repository" {
  name = "foo-doo-emr-eks-spark-image"
  force_delete = true
}

// Outputs
output "emr_eks_repository_url" {
  description = "The ECR repository for EMR on EKS"
  value       = aws_ecr_repository.emr-eks-repository.repository_url
}
