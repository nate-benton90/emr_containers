// Variables
variable "lambda_execution_role_name" {
  description = "The name of the IAM role that the Lambda function will assume"
  type        = string
}

// Resources
resource "null_resource" "lambda_package" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOF
    powershell.exe -File ./infra/lambda/runtimes/packager.ps1
  EOF
  }
}

# TODO: add depednecy on null_resource.lambda_package
resource "aws_lambda_function" "start_emr_container_job" {
  filename      = "./infra/lambda/runtimes/lambda_function_payload.zip"
  function_name = "start_job"
  role          = var.lambda_execution_role_name
  handler       = "config_emr_eks_job.main"
  runtime       = "python3.10"
}
