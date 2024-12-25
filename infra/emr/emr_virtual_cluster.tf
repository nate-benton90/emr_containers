// Variables
variable eks_cluster_name {
  description = "The name of the EKS cluster used to run EMR Container jobs"
  type        = string
}

variable emr_eks_id_mapping {
  description = "The ID of the EKS cluster to use for EMR Container jobs"
  type        = string
}

resource "null_resource" "poll_eks_status" {
  depends_on = [var.emr_eks_id_mapping, var.eks_cluster_name]
  provisioner "local-exec" {
    command = "powershell -NoProfile -File ./infra/emr/check_eks_status.ps1"
  }
}

// Resources
resource "aws_emrcontainers_virtual_cluster" "foo-emr-virtual-cluster" {
  name = "emr-eks-fun-time"
  depends_on = [var.emr_eks_id_mapping, var.eks_cluster_name]
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
