# Variables
variable "region" {
  default = "us-east-1"
}

variable "account_id" {
  default = "640048293282"
}

variable "repository_url" {
  default = "640048293282.dkr.ecr.us-east-1.amazonaws.com/foo-doo-emr-eks-spark-image"
}

variable "image_path" {
  default = "./images"
}

# Resources
resource "null_resource" "push_docker_image" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOF
    powershell.exe -File ./images/login_build_push.ps1 -Region "${var.region}" -AccountId "${var.account_id}" -RepositoryUrl "${var.repository_url}" -ImagePath "${var.image_path}"
    EOF
  }
}
