// Variables
variable "region" {
  description = "The AWS region to deploy to"
  default     = "us-west-1"
}

variable "account_id" {
  description = "The AWS account ID"
}

variable "repository_url" {
  description = "The name of the ECR repository"
}

// Resources
resource "null_resource" "push_docker_image" {
  # NOTE: this ensures that the local-exec provisioner runs every time for every apply 
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOF
    powershell.exe -File ./images/login_build_push.ps1
  EOF
  }
}

# TODO: replace hard-coded values
# TODO: add command to seperate ps1 file
resource "null_resource" "delete_images" {
  provisioner "local-exec" {
    command = "aws ecr batch-delete-image --repository-name foo-doo-emr-eks-spark-image --image-ids imageTag=latest --region us-east-1"
    when    = destroy
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [
    var.repository_url
  ]
}
