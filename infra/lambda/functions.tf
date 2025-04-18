# FUNCTION 1: EMR Container Lambda ------------------------------------------------------------------------------------
// Variables
variable "lambda_execution_role_name" {
  description = "The name of the IAM role that the Lambda function will assume"
  type        = string
}

// Data
# Calculate a hash of the Python code files to detect changes
data "local_file" "python_files" {
  filename = "./infra/lambda/runtimes/config_emr_eks_job.py" # Main Python file or zip file
}

// Resources
resource "null_resource" "lambda_package" {
  triggers = {
    always_run = "${timestamp()}"
    code_hash = filebase64sha256("./infra/lambda/runtimes/lambda_function_payload.zip") # Hash of the zip file
  }
  provisioner "local-exec" {
    command = <<EOF
    powershell.exe -File ./infra/lambda/runtimes/packager.ps1
    EOF
  }
}

# TODO: also, refactor paths
resource "aws_lambda_function" "start_emr_container_job" {
  filename         = "./infra/lambda/runtimes/lambda_function_payload.zip"
  function_name    = "start_emr_container_job"
  role             = var.lambda_execution_role_name
  handler          = "config_emr_eks_job.main"
  runtime          = "python3.10"
  depends_on       = [null_resource.lambda_package]
}
