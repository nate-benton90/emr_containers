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

variable "eks_security_group_id" {
  default = "sg-nothing"
}

variable subnet_id {
  default = "subnet-nothing"
}

// Resources
# NOTE: move this IAM stuff to the correct dir later
resource "aws_iam_role" "ssm_role" {
  name = "EC2SSMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ssm_policy_attachment" {
  name       = "ssm-policy-attachment"
  roles      = [aws_iam_role.ssm_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "EC2SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "docker_builder" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name  # Attach SSM Profile
  user_data = file("${path.module}/bootstrap.sh")
  vpc_security_group_ids = [var.eks_security_group_id]
  tags = {
    Name = "docker-builder-instance"
  }
}

# TODO: add this to vpc section instead of here
# resource "aws_security_group" "docker_builder_sg" {
#   name_prefix = "docker-builder-sg"

#   description = "Security group for isolated Docker builder EC2 instance"
#   vpc_id      = var.vpc_id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
#   }

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = [] # Deny all inbound traffic
#   }
# }

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
