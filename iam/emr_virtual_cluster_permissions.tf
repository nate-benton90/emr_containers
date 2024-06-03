// Variables
variable eks_cluster_name {
  description = "The name of the EKS cluster used to run EMR Container jobs"
  type        = string
}

// Resource
resource "aws_iam_role" "emr_role" {
  name = "emr_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "emr-containers.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "emr_policy" {
  name        = "emr_policy"
  description = "Policy for EMR Containers"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "emr-containers:",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "emr_policy_attachment" {
  role       = aws_iam_role.emr_role.name
  policy_arn = aws_iam_policy.emr_policy.arn
}

# TODO: change resource below with variables
resource "null_resource" "emr_eks_id_mapping" {
  depends_on = [aws_eks_cluster.foo-emr-eks-cluster]
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOF
    powershell.exe -File ./iam/eksctl_id_mapping.ps1
  EOF
  }
}

// Output
output "emr_role" {
  description = "The IAM role for EMR"
  value       = aws_iam_role.emr_role.arn
}

output "emr_policy" {
  description = "The IAM policy for EMR"
  value       = aws_iam_policy.emr_policy.arn
}