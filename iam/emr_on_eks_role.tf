// Variables
variable "region" {
  description = "AWS region"
}

variable "account_id" {
  description = "AWS account ID"
}

// Resources
resource "aws_iam_role" "emr_on_eks_role" {
  name        = "emr-on-eks-pod-role"
  description = "IAM role for EMR on EKS which is passed via Lambda when starting a job"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "emr_on_eks_pod_policy" {
  name = "emr-on-eks-pod-policy"
  role = aws_iam_role.emr_on_eks_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      },
      {
        Sid = "LakeFormationAllow"
        Effect = "Allow"
        Action = [
          "lakeformation:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "managed_policy_attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole",
    "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforAutoScalingRole"
  ])
  
  role       = aws_iam_role.emr_on_eks_role.name
  policy_arn = each.value
}
