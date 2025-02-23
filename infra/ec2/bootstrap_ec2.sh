#!/bin/bash
set -e

echo "Starting EC2 bootstrap script..."

# Install System Updates
echo "Updating system packages..."
sudo yum update -y

# Install Amazon SSM Agent
echo "Installing Amazon SSM Agent..."
sudo yum install -y amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Install Required Dependencies
echo "Installing dependencies (Docker, AWS CLI, jq)..."
amazon-linux-extras enable docker
sudo yum install -y docker jq aws-cli

# Start and enable Docker
echo "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Wait for Docker to be ready
echo "Waiting for Docker to be available..."
until sudo docker ps > /dev/null 2>&1; do
    sleep 5
done
echo "Docker is running."

# Authenticate with AWS ECR
echo "Authenticating with AWS ECR..."
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${emr_eks_repository_url}

# Define Docker image variables
BASE_IMAGE="public.ecr.aws/emr-on-eks/spark:emr-7.0.0-latest"
CUSTOM_IMAGE="${emr_eks_repository_url}:latest"

# Pull Base Image
echo "Pulling base image: $BASE_IMAGE..."
docker pull $BASE_IMAGE

# Create Dockerfile for customization
echo "Creating Dockerfile..."
cat <<EOF > /home/ec2-user/Dockerfile
FROM $BASE_IMAGE
RUN echo "Customizing Spark Image" >> /custom-log.txt
EOF

# Build Docker Image
echo "Building Docker image..."
docker build -t $CUSTOM_IMAGE /home/ec2-user

# Push Docker Image to ECR
echo "Pushing Docker image to ECR..."
docker push $CUSTOM_IMAGE

echo "Bootstrap script completed successfully!"
