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
resource "aws_ecr_repository" "repository" {
  name = "foo-emr-eks-spark-image"
}

resource "null_resource" "push_docker_image" {
  provisioner "local-exec" {
    command = <<EOF
    powershell.exe -File ./images/login_build_push.ps1
  EOF
  }
}
