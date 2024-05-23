# TODO: replace id value with variables usage for EKS cluster
resource "aws_emrcontainers_virtual_cluster" "foo-emr-virtual-cluster" {
  container_provider {
    id   = "foo-emr-eks-cluster"
    type = "EKS"
    info {
      eks_info {
        namespace = "emr-containers"
      }
    }
  }
  name = "emr-eks-fun-time"
}