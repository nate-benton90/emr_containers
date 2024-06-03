// Variables
variable emr_role_arn {
  description = "The ARN of the IAM role to use for EMR"
  type        = string
}

variable emr_policy_arn {
  description = "The ARN of the IAM policy to use for EMR"
  type        = string
}

variable eks_cluster_name {
  description = "The name of the EKS cluster used to run EMR Container jobs"
  type        = string
}

// Resources
# TODO: replace id value with variables usage for EKS cluster
resource "aws_emrcontainers_virtual_cluster" "foo-emr-virtual-cluster" {
  name = "emr-eks-fun-time"
  depends_on = [aws_eks_cluster.foo-emr-eks-cluster]
  container_provider {
    id   = module.eks.eks_cluster_name
    type = "EKS"
    info {
      eks_info {
        namespace = "emr-on-eks"
      }
    }
  }
}
