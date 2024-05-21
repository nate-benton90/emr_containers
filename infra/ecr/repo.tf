resource "aws_ecr_repository" "emr-eks-repository" {
  name = "emr-eks-images"
}

output "emr_eks_repository" {
  description = "The ECR repository for EMR on EKS"
  value       = aws_ecr_repository.emr-eks-repository.repository_url
}
