// Variables
variable "eks_cluster_name" {
  description = "The name of the EKS cluster used to run EMR Container jobs"
  type        = string
}

variable "emr_eks_id_mapping" {
  description = "The ID of the EKS cluster to use for EMR Container jobs"
  type        = string
}

variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
}

// Null Resource
resource "null_resource" "poll_eks_status" {
  provisioner "local-exec" {
    command = "powershell -NoProfile -File ./infra/emr/check_eks_status.ps1"
  }
}

// EMR Virtual Cluster Resource
resource "aws_emrcontainers_virtual_cluster" "foo-emr-virtual-cluster" {
  name = "emr-eks-fun-time"
  depends_on = [null_resource.poll_eks_status, var.node_group_name] // Explicit dependency on the null_resource

  container_provider {
    id   = var.eks_cluster_name
    type = "EKS"
    info {
      eks_info {
        namespace = "emr-on-eks"
      }
    }
  }
}
