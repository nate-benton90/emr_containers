# Replace these variables with actual values or use build arguments
ARG ACCOUNT_ID=755674844232
ARG REGION=us-east-1
ARG REPO_NAME=spark
ARG IMAGE_TAG=emr-7.0.0:latest

FROM public.ecr.aws/emr-on-eks/spark/${IMAGE_TAG}
LABEL maintainer="foo_nobody"
LABEL owner_email="nbenton90@gmail.com" 
ENV SPARK_VERSION=3.2

# install wget
RUN yum install wget -y && yum upgrade -y

# import AWS certificates
RUN wget -P /tmp https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem
RUN keytool -import -trustcacerts -alias aws -file /tmp/rds-combined-ca-bundle.pem -keystore /usr/lib/jvm/jre/lib/security/cacerts -storepass changeit -noprompt

# update SSM Agent
RUN yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# install libraries
# RUN yum install -y python3-devel libtiff-devel libjpeg-devel zlib-devel freetype-devel lcms2-devel libwebp-devel tcl-devel tk-devel harfbuzz-devel fribidi-devel libraqm-devel libimagequant-devel libxcb-devel
RUN python3 -m pip install --no-cache-dir --upgrade s3fs==0.4.2 networkx==2.4 requests-aws4auth==1.1.1 boto3==1.17.97 py4j==0.10.9.6

USER hadoop:hadoopie
