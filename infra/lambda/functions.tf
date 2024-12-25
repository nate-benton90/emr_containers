# FUNCTION 1: EMR Container Lambda ------------------------------------------------------------------------------------ 
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

# resource "aws_lambda_layer_version" "lambda_layer" {
#   filename = "layer.zip"
#   source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
#   layer_name = "emr_container_layer"
#   compatible_runtimes = ["python3.10"]
#   depends_on = [
#     data.archive_file.zip_the_python_code
#   ]
# }

# TODO: also, refactor paths
resource "aws_lambda_function" "start_emr_container_job" {
  filename         = "./infra/lambda/runtimes/lambda_function_payload.zip"
  function_name    = "start_emr_container_job"
  role             = var.lambda_execution_role_name
  handler          = "config_emr_eks_job.main"
  runtime          = "python3.10"
  depends_on = [null_resource.lambda_package]
}
