// Resources
resource "aws_lambda_function" "start_emr_container_job" {
  filename      = "./lambda_function_payload.zip"
  function_name = "start_job"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_handler.main"
  runtime       = "python3.10"
}
