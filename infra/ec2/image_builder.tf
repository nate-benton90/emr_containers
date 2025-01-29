// Variables
variable "region" {
  default = "us-east-1"
}

variable "emr_eks_repository_url" {
  default = "foo-doo-emr-eks-spark-image"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "vpc_id" {
  default = "vpc-nothing"
}

variable "ec2_role" {
  default = "nothing:D"
}


// Resources
resource "aws_instance" "docker_builder" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = var.instance_type

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # User data script to automate Docker setup and ECR push
  user_data = <<-EOT
    #!/bin/bash
    set -e

    # Install Docker
    amazon-linux-extras enable docker
    yum install -y docker
    service docker start
    usermod -a -G docker ec2-user

    # Authenticate with ECR
    $(aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.emr_eks_repository_url})

    # Pull Base Image
    docker pull public.ecr.aws/emr-on-eks/spark:emr-7.0.0-latest

    # Customize the Docker Image
    cat <<EOF > Dockerfile
    FROM public.ecr.aws/emr-on-eks/spark:emr-7.0.0-latest
    RUN echo "Customizing Spark Image" >> /custom-log.txt
    EOF

    docker build -t ${var.emr_eks_repository_url} .

    # Push to ECR
    docker push ${var.emr_eks_repository_url}
  EOT

  # Assign a security group with no inbound access
  vpc_security_group_ids = [aws_security_group.docker_builder_sg.id]

  tags = {
    Name = "docker-builder-instance"
  }
}

# TODO: add this to vpc section instead of here
resource "aws_security_group" "docker_builder_sg" {
  name_prefix = "docker-builder-sg"

  description = "Security group for isolated Docker builder EC2 instance"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [] # Deny all inbound traffic
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-docker-profile"
  role = var.ec2_role
}

// Outputs
output "ec2_instance_id" {
  value = aws_instance.docker_builder.id
}

output "ec2_public_ip" {
  value = aws_instance.docker_builder.public_ip
}
