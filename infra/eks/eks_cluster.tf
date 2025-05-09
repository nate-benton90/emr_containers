// Variables
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

// Resources
resource "aws_eks_cluster" "foo-emr-eks-cluster" {
  name     = "foo-emr-eks-cluster"
  role_arn = var.role_arn
  vpc_config {
    subnet_ids = var.eks_subnet_ids
  }
}

# TODO: move this section of sg, vpc, subnets, etc. into VPC directory
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
  # NOTE: this key part below must exist on your local machine
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
  instance_types = ["t3.medium"]
  # NOTE: instance and image type need to be able to host the architecture of the image for the emr-eks job (see Dockerfile)
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

// Data sources
data "aws_eks_cluster" "example" {
  name = aws_eks_cluster.foo-emr-eks-cluster.name
}

data "aws_eks_cluster_auth" "example" {
  name = aws_eks_cluster.foo-emr-eks-cluster.name
}

// Provider
# TODO: move this over to the main.tf file or elsewhere
provider "kubernetes" {
  host                   = data.aws_eks_cluster.example.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.example.token
}

resource "kubernetes_namespace" "emr" {
  metadata {
    name = "emr-on-eks"
  }
}

// Output
output "eks_cluster_name" {
  value = aws_eks_cluster.foo-emr-eks-cluster.name
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.foo-emr-eks-cluster.arn
}

output kubernetes_namespace {
  value = kubernetes_namespace.emr.metadata.0.name
}

output node_group_name {
  value = aws_eks_node_group.emr-eks-node-group-foo.node_group_name
}

output security_group_id {
  value = aws_security_group.eks_node_group_sg.id
}

output subnet_ids {
  value = aws_eks_node_group.emr-eks-node-group-foo.subnet_ids
}