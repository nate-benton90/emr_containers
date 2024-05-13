module "emr_virtual_cluster" {
  source = "terraform-aws-modules/emr/aws//modules/virtual-cluster"

  name             = "emr-custom"
  create_namespace = true
  namespace        = "emr-custom"

  create_iam_role = true
  s3_bucket_arns = [
    "arn:aws:s3:::/my-elasticmapreduce-bucket",
    "arn:aws:s3:::/my-elasticmapreduce-bucket/*",
  ]
  role_name                     = "emr-custom-role"
  iam_role_use_name_prefix      = false
  iam_role_path                 = "/"
  iam_role_description          = "EMR custom Role"
  iam_role_permissions_boundary = null
  iam_role_additional_policies  = []

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
