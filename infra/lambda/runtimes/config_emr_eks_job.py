import os
import time
import json
import uuid
import boto3
import logging

# ---------------------------------------------------------------------------------------------

# NOTE: setup global logging
log = logging.getLogger(__name__)
logging.basicConfig(level = logging.DEBUG)
log_handler = logging.StreamHandler()
log_handler.setFormatter(logging.Formatter(fmt='%(asctime)s  %(levelname)s  %(message)s',
                                           datefmt='%Y-%m-%d %H:%M:%S'))
log.addHandler(log_handler)
log.setLevel(logging.INFO)
log.info('***logger initialized')

# NOTE: read env vars and set global vars
# virtual_cluster_id = os.getenv("EMR_VIRTUAL_CLUSTER_ID")
virtual_cluster_id = "l8lxg71502x30f6y3059z0731"
log.info("***referencing virtual cluster id {0} via module {1}".format(virtual_cluster_id,
                                                                os.path.basename(__file__)))

# ---------------------------------------------------------------------------------------------

# TODO: add vars below
S3_EMR_LOGS_BUCKET = os.getenv('LOGS_BUCKET')
EMR_CONTAINER_LOGS_PATH = "s3://{0}/emr_containers/".format(S3_EMR_LOGS_BUCKET)
SCRIPTS_BUCKET = os.getenv('S3_SCRIPT_BUCKET')
ACOE_ACCOUNT_ID = os.getenv('ACOE_ACCOUNT_ID')

# --------------------------------------------------------------------------------------------

def default_emr_container_job_configuration_overrides() -> dict:
    """
    *input payload for emr container start job
    """
    # TODO: add vars for this: spark.kubernetes.container.image
    return {
            "applicationConfiguration": [
                {
                    "classification": "spark-env",
                    "properties": {},
                    "configurations": [
                        {
                            "classification": "export",
                            "properties": {
                                "PYSPARK_PYTHON": "/usr/bin/python3"
                            },
                            "configurations": []
                        }
                    ]
                },
                {
                    "classification": "spark-defaults",
                    "properties": {
                        "spark.sql.execution.arrow.enabled": "true",
                        "spark.memory.offHeap.enabled": "true",
                        "spark.memory.offHeap.size": "5g",
                        "spark.sql.debug.maxToStringFields": "100",
                        "spark.ssl.enabled": "true",
                        "spark.eventLog.enabled": "true",
                        "spark.kubernetes.container.image": "{0}.dkr.ecr.us-east-1.amazonaws.com/foo-doo-emr-eks-spark-image:latest".format("640048293282"),
                        "spark.jars.packages": "org.json4s:json4s-jackson:3.2.11",
                        "spark.speculation": "false"
                    },
                    "configurations": []
                },
                {
                    "classification": "spark-hive-site",
                    "properties": {
                        "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory",
                        "hive.metastore.schema.verification": "false",
                        "hive.exec.dynamic.partition": "true",
                        "hive.exec.dynamic.partition.mode": "nonstrict",
                        "spark.hadoop.hive.metastore.glue.catalogid": "{0}".format("640048293282"),
                        "spark.hadoop.fs.s3.maxRetries": "5"
                    },
                    "configurations": []
                },
                {
                    "classification": "emrfs-site",
                    "properties": {
                        "fs.s3.useRequesterPaysHeader": "true",
                        "fs.s3.maxRetries": "1"
                    },
                    "configurations": []
                }
            ],
            "monitoringConfiguration": {
                "persistentAppUI": "ENABLED",
                "cloudWatchMonitoringConfiguration": {
                    "logGroupName": "/emr-containers/jobs",
                    "logStreamNamePrefix": "emr-continer-job-runs"
                },
                "s3MonitoringConfiguration": {
                "logUri": "{0}".format("s3://emr-containers-foodoo-data/emr-logs/")
                }
            }
    }

# ---------------------------------------------------------------------------------------------

def make_spark_submit_parameters():
    """
    *default,test parameters for spark-submit that should be customized according to arguments and awareness of
    limits/shresholds of eks cluster and pod
    """
    sparkSubmitParameters = "--conf spark.sql.sources.partitionOverwriteMode=dynamic  --conf spark.executor.instances=1 \
                                --conf spark.executor.memory=3G --conf spark.driver.memory=3G --conf spark.executor.cores=1 \
                                --conf spark.authenticate=false --conf spark.shuffle.service.enabled=false --conf spark.network.crypto.enabled=false \
                                --conf spark.authenticate.enableSaslEncryption=false"
    return sparkSubmitParameters

def start_emr_container_job(event_param, context_param=None):

    # TODO: add vars for this
    emr_container_job_driver = \
                                {
                                    "sparkSubmitJobDriver": {
                                                "entryPoint": "s3://foo-doo-who-emr-container-scripts/pyspark/emr_container_job_template.py",
                                                "entryPointArguments": ["key_1", "value_1"],
                                                "sparkSubmitParameters": make_spark_submit_parameters(),
                                                }
                                }

    print("***emr-container job driver: {0}".format(emr_container_job_driver))

    try:
        emrc_client = boto3.client('emr-containers')
        log.debug("***emr-container client established with this setup: {0}".format(emrc_client))
    except Exception as error:
        log.error("***emr-container client failed to establish: {0}".format(error))
        raise error
    
    # TODO: add variable to lambda to replace aws account number
    start_job_run_response = emrc_client.start_job_run(
                name="emr-container-job-{0}".format(int(time.time())),
                virtualClusterId=virtual_cluster_id,
                clientToken=str(uuid.uuid4()),
                executionRoleArn="arn:aws:iam::640048293282:role/emr-on-eks-pod-role",
                releaseLabel="emr-7.2.0-latest",
                jobDriver=emr_container_job_driver,
                configurationOverrides=default_emr_container_job_configuration_overrides()
    )

    return start_job_run_response

def main(event_arg, context_arg=None):

    # NOTE: before running start_emr_container_job below, combine input args with default pyspark config overrides
    all_lambda_input = {**event_arg}
    return start_emr_container_job(event_arg, context_arg)

# --------------------------------------------------------------------------------------------

if __name__ == '__main__':
    main(event, context)
