resource "aws_instance" "docker_builder" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOT
    #!/bin/bash
    set -e

    # Install Docker
    amazon-linux-extras enable docker
    yum install -y docker
    service docker start
    usermod -a -G docker ec2-user

    # Authenticate with ECR
    $(aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.docker_repo.repository_url})

    # Pull Base Image
    docker pull public.ecr.aws/emr-on-eks/spark:emr-7.0.0-latest

    # Customize the Docker Image
    cat <<EOF > Dockerfile
    FROM public.ecr.aws/emr-on-eks/spark:emr-7.0.0-latest
    RUN echo "Customizing Spark Image" >> /custom-log.txt
    EOF

    docker build -t ${aws_ecr_repository.docker_repo.repository_url}:custom .

    # Push to ECR
    docker push ${aws_ecr_repository.docker_repo.repository_url}:custom
  EOT

  tags = {
    Name = "docker-builder-instance"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-docker-profile"
  role = aws_iam_role.ec2_role.name
}
