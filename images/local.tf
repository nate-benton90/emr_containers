provider "aws" {
  region  = var.region
}

resource "aws_ecr_repository" "repository" {
  name = "my-ecr-repo"
}

resource "null_resource" "push_docker_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
      $(aws ecr get-login --no-include-email --region ${var.region})
      docker build -t ${aws_ecr_repository.repository.repository_url}:latest .
      docker push ${aws_ecr_repository.repository.repository_url}:latest
    EOF
  }
}
