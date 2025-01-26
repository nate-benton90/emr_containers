# NOTE 1]: get more specific parents images here for aws: https://gallery.ecr.aws/emr-on-eks?page=1
# NOTE 2]: get more general info for customizing images here: https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/docker-custom-images-steps.html 
FROM public.ecr.aws/emr-on-eks/spark/emr-7.2.0:20241010-x86_64
LABEL owmner="foo_nobody"
LABEL owner_email="nbenton90@gmail.com" 
ENV SPARK_VERSION=3.2

# switch to root user for package installation
USER root

# install wget and update system packages
RUN yum update -y && yum upgrade -y && yum install -y wget

# import AWS certificates
RUN wget -P /tmp https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem
RUN keytool -import -trustcacerts -alias aws -file /tmp/rds-combined-ca-bundle.pem -keystore /usr/lib/jvm/jre/lib/security/cacerts -storepass changeit -noprompt

# update SSM Agent
# RUN yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Install libraries
RUN python3 -m pip install --no-cache-dir --upgrade s3fs==0.4.2 networkx==2.4 requests-aws4auth==1.1.1 boto3==1.17.97 py4j==0.10.9.6

# switch back to non-root user
USER hadoop:hadoopie
