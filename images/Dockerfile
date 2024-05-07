FROM emr-6.7.0
LABEL maintainer="foo_nobody"
LABEL owner_email="nbenton90@gmail.com"
ENV SPARK_VERSION=3.2
USER root

# install wget
RUN yum install wget -y && yum upgrade -y

# import AWS certificates
RUN wget -P /tmp https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem
RUN keytool -import -trustcacerts -alias aws -file /tmp/rds-combined-ca-bundle.pem -keystore /usr/lib/jvm/jre/lib/security/cacerts -storepass changeit -noprompt

# update SSM Agent
RUN yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# install libraries
RUN yum install -y python3-devel libtiff-devel libjpeg-devel openjpeg2-devel zlib-devel freetype-devel lcms2-devel libwebp-devel tcl-devel tk-devel harfbuzz-devel fribidi-devel libraqm-devel libimagequant-devel libxcb-devel
RUN python3 -m pip install --no-cache-dir --upgrade pandas==1.0.5 matplotlib==3.3.0 s3fs==0.4.2 pyarrow==0.14.1 pyathena==1.11.0 newrelic==5.22.1.152 networkx==2.4 numpy==1.19.1 requests-aws4auth==1.1.1 psycopg2-binary==2.8.6 boto3==1.17.97 pydeequ py4j==0.10.9.6

USER hadoop:hadoop
