// Variables
variable emr_role_arn {
  description = "The ARN of the IAM role to use for EMR"
  type        = string
}

variable emr_policy_arn {
  description = "The ARN of the IAM policy to use for EMR"
  type        = string
}

// Resources
# TODO: replace id value with variables usage for EKS cluster
# Create the EMR virtual cluster
resource "aws_emrcontainers_virtual_cluster" "foo-emr-virtual-cluster" {
  name = "emr-eks-fun-time"
  container_provider {
    id   = "foo-emr-eks-cluster"
    type = "EKS"
    info {
      eks_info {
        namespace = "default"
      }
    }
  }
}
