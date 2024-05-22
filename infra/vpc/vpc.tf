resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "eks_vpc"
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks_igw"
  }
}

resource "aws_route_table" "eks_public_rt" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }
  tags = {
    Name = "eks_public_rt"
  }
}

resource "aws_subnet" "eks_subnet" {
  count = 2
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = count.index == 0 ? "10.0.1.0/24" : "10.0.2.0/24"
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "eks_subnet_${count.index}"
    "kubernetes.io/cluster/foo-emr-eks-cluster" = "shared"
  }
}

resource "aws_route_table_association" "eks_subnet_association" {
  count = 2
  subnet_id      = element(aws_subnet.eks_subnet[*].id, count.index)
  route_table_id = aws_route_table.eks_public_rt.id
}

output "eks_vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.eks_vpc.id
}

output "eks_subnet_ids" {
  description = "The IDs of the subnets"
  value       = aws_subnet.eks_subnet[*].id
}
