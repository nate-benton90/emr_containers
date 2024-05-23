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

# Create the IAM policy
resource "aws_iam_policy" "emr_policy" {
  name        = "emr_policy"
  description = "Policy for EMR Containers"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "emr-containers:DescribeNamespace",
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "emr_policy_attachment" {
  role       = aws_iam_role.emr_role.name
  policy_arn = aws_iam_policy.emr_policy.arn
}

# Create the EMR virtual cluster
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
  execution_role_arn = aws_iam_role.emr_role.arn  # Associate the IAM role with the EMR virtual cluster
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