# TODO: add variables to all usage of account ID, region, and ecr repo name
# Step 1: Log in to AWS ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 640048293282.dkr.ecr.us-east-1.amazonaws.com

# Step 2: Build the Docker image
docker build -t 640048293282.dkr.ecr.us-east-1.amazonaws.com/foo-emr-eks-spark-image:latest ./images

# Step 3: Push the Docker image to ECR
docker push 640048293282.dkr.ecr.us-east-1.amazonaws.com/foo-emr-eks-spark-image:latest
