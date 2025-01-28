# TODO: add variables to all usage of account ID, region, and ecr repo name
# NOTE: the path path to the image
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 640048293282.dkr.ecr.us-east-1.amazonaws.com

docker build -t 640048293282.dkr.ecr.us-east-1.amazonaws.com/foo-doo-emr-eks-spark-image:latest ./images

docker push 640048293282.dkr.ecr.us-east-1.amazonaws.com/foo-doo-emr-eks-spark-image:latest
