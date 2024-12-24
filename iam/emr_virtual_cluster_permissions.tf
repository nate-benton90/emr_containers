// Variables
variable eks_cluster_name {
  description = "The name of the EKS cluster used to run EMR Container jobs"
  type        = string
}

variable kubernetes_namespace {
  description = "The namespace of the EKS cluster"
  type        = string
}

// Resources
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
      "Action": "emr-containers:*",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "emr_policy_eks" {
  name        = "eks_policy"
  description = "Policy for to enable EMR Containers to create namespaces on EKS"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "eks:*",
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

resource "aws_iam_role_policy_attachment" "emr_policy_attachment_2" {
  role       = aws_iam_role.emr_role.name
  policy_arn = aws_iam_policy.emr_policy_eks.arn
}

# TODO: change resource below with variables
resource "null_resource" "emr_eks_id_mapping" {
  depends_on = [
    var.eks_cluster_name,
    var.kubernetes_namespace,
  ]
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOF
    powershell.exe -File ./iam/eksctl_id_mapping.ps1
  EOF
  }
}

// Outputs
output "emr_role" {
  description = "The IAM role for EMR"
  value       = aws_iam_role.emr_role.arn
}

output "emr_policy" {
  description = "The IAM policy for EMR"
  value       = aws_iam_policy.emr_policy.arn
}

output "emr_eks_id_mapping" {
  value = null_resource.emr_eks_id_mapping.id
  description = "The unique identifier of the null_resource"
}
