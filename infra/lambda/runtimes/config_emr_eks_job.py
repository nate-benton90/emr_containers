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
virtual_cluster_id = os.getenv("EMR_VIRTUAL_CLUSTER_ID")
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
    # TODO: remove or provide conditional variable for this: "spark.jars.packages": "com.amazon.deequ:deequ:2.0.1-spark-3.2"
    # TODO: add vars for this: spark.kubernetes.container.image
    return {
        "configurationOverrides": {
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
                        "spark.kubernetes.container.image": "{0}.dkr.ecr.us-east-1.amazonaws.com/foo-doo-emr-eks-spark-image:latest".format("xxx"),
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
                        "spark.hadoop.hive.metastore.glue.catalogid": "{0}".format("xxx"),
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
                "logUri": "{0}".format("xxx")
                }
            }
        }
    }

# ---------------------------------------------------------------------------------------------

# def recursive_dict_key_value_search(key, iterable):
#     """
#     recursively search for a key in an iterable that may contain dictionaries and return its value.
#     """
#     if isinstance(iterable, dict):
#         if key in iterable:
#             return iterable[key]
#         else:
#             for value in iterable.values():
#                 result = recursive_dict_key_value_search(key, value)
#                 if result is not None:
#                     return result
#     elif isinstance(iterable, (list, tuple)):
#         for item in iterable:
#             result = recursive_dict_key_value_search(key, item)
#             if result is not None:
#                 return result
#     return None

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
    event_input['Input']['job_driver']['sparkSubmitJobDriver']['sparkSubmitParameters'] = spark_submit_parameters

    emr_container_job_driver = recursive_dict_key_value_search("job_driver", event_input)
    emr_container_job_configuration_overrides = recursive_dict_key_value_search("configurationOverrides", event_input)

    try:
        emrc_client = boto3.client('emr-containers')
        log.debug("***emr-container client established with this setup: {0}".format(emrc_client))
    except Exception as error:
        log.error("***emr-container client failed to establish: {0}".format(error))
        raise error
    
    start_job_run_response = emrc_client.start_job_run(
                name="foo-emr-container-job-{0}".format(int(time.time())),
                virtualClusterId=virtual_cluster_id,
                clientToken=str(uuid.uuid4()),
                executionRoleArn=emr_container_job_iam_role,
                releaseLabel=emr_container_release_label,
                jobDriver=emr_container_job_driver,
                configurationOverrides=emr_container_job_configuration_overrides
    )

    return start_job_run_response

def main(event_arg, context_arg=None):

    # NOTE: before running start_emr_container_job below, combine input args with default pyspark config overrides
    event_arg = {**event_arg, **default_emr_container_job_configuration_overrides()}
    return start_emr_container_job(event_arg, context_arg)

# --------------------------------------------------------------------------------------------

if __name__ == '__main__':
    main(event, context)
