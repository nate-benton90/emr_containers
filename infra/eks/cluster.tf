variable "eks_vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "eks_subnet_ids" {
  description = "The IDs of the subnets"
  type        = list(string)
}

variable "role_arn" {
  description = "The ARN of the IAM role to use for EKS"
  type        = string
}

variable "node_role_arn" {
  description = "The ARN of the IAM role to use for EKS node group"
  type        = string
}

resource "aws_eks_cluster" "foo-emr-eks-cluster" {
  name     = "foo-emr-eks-cluster"
  role_arn = var.role_arn
  vpc_config {
    subnet_ids = var.eks_subnet_ids
  }
}

resource "aws_security_group" "eks_node_group_sg" {
  name_prefix = "eks-node-group-"
  vpc_id      = var.eks_vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-group-sg"
  }
}

# NOTE: Adjust the path to your SSH public key
resource "aws_key_pair" "eks_key_pair" {
  key_name   = "eks_key_pair"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_eks_node_group" "emr-eks-node-group-foo" {
  depends_on = [aws_eks_cluster.foo-emr-eks-cluster]
  cluster_name    = aws_eks_cluster.foo-emr-eks-cluster.name
  node_group_name = "emr-eks-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.eks_subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.micro"]
  ami_type = "AL2_x86_64"
  capacity_type = "SPOT"
  
  labels = {
    usage = "test-cluster"
  }

  remote_access {
    ec2_ssh_key = aws_key_pair.eks_key_pair.key_name
    source_security_group_ids = [aws_security_group.eks_node_group_sg.id]
  }
  
  tags = {
    Name = "emr-eks-node-group"
  }
}
