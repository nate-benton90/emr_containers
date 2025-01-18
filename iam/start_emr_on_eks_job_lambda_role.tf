resource "aws_iam_role" "lambda_emr_role" {
  name               = "start-emr-container-job-lambda-role"
  description        = "IAM role for Lambda which starts the EMR on EKS job"
  
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

resource "aws_iam_role_policy" "logs_access_policy" {
  name   = "cci-svc-dq-emr-containers-startemrc-job"
  role   = aws_iam_role.lambda_emr_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:CreateLogStream"
        ]
        Resource = "*"
      },
      {
        Sid = "AllowEmrCStartJob"
        Effect = "Allow"
        Action = [
          "emr-containers:StartJobRun",
          "emr-containers:CancelJobRun"
        ]
        Resource = "*"
      },
      {
        Sid = "RequiredEc2Actions"
        Effect = "Allow"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}
