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
   force_delete = true
}

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

# resource "null_resource" "ecr_empty_repo" {
#   provisioner "local-exec" {
#     command = "powershell.exe -File delete_images.ps1"
#   }

#   depends_on = [
#     aws_ecr_repository.foo-emr-eks-spark-image
#   ]
# }

# resource "null_resource" "destroy_ecr" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }

#   provisioner "local-exec" {
#     command = "terraform destroy -target=aws_ecr_repository.foo-emr-eks-spark-image"
#   }

#   depends_on = [
#     null_resource.ecr_empty_repo
#   ]
# }