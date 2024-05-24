// Resources
resource "aws_iam_role" "start_job_lambda_role" {
  name = "start_job_lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attach" {
  role       = aws_iam_role.start_job_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// Outputs
output "start_job_lambda_role" {
  description = "The IAM role for the start job lambda"
  value       = aws_iam_role.start_job_lambda_role.arn
}
