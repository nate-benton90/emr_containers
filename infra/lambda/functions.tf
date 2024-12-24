// Variables
variable "lambda_execution_role_name" {
  description = "The name of the IAM role that the Lambda function will assume"
  type        = string
}

// Resources
resource "null_resource" "lambda_package" {
  triggers = {
    script_sha = filesha256("./infra/lambda/runtimes/config_emr_eks_job.py")
  }
  provisioner "local-exec" {
    command = "cd ./infra/lambda/runtimes; Compress-Archive -Path ./config_emr_eks_job.py -DestinationPath ./lambda_function_payload.zip"
  }
}

resource "aws_lambda_function" "start_emr_container_job" {
  filename         = "./infra/lambda/runtimes/lambda_function_payload.zip"
  function_name    = "start_job"
  role             = var.lambda_execution_role_name
  handler          = "config_emr_eks_job.main"
  runtime          = "python3.10"
  source_code_hash = filebase64sha256("./infra/lambda/runtimes/lambda_function_payload.zip")
  depends_on = [null_resource.lambda_package]
}
