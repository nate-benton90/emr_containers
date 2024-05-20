# module "emr_virtual_cluster" {
#   source = "terraform-aws-modules/emr/aws//modules/virtual-cluster"
#   name             = "emr-containers"
#   create_namespace = true
#   namespace        = "emr-containers"
#   create_iam_role = true
#   s3_bucket_arns = [module.s3.s3_bucket_arn]
#   role_name                     = module.iam.aws_iam_role.arn
#   iam_role_use_name_prefix      = false
#   iam_role_path                 = "/"
#   iam_role_description          = "EMR custom Role"
#   iam_role_permissions_boundary = null
#   iam_role_additional_policies  = []
#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }

resource "aws_emrcontainers_virtual_cluster" "example" {
  container_provider {
    id   = "asdfasdf12341234"
    type = "EKS"
    info {
      eks_info {
        namespace = "default"
      }
    }
  }
  name = "example"
}