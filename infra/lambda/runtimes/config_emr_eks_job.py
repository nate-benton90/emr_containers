import os
import time
import json
import boto3
import logging

# ---------------------------------------------------------------------------------------------

# NOTE: setup logging
log = logging.getLogger(__name__)
log_handler = logging.StreamHandler()
log_handler.setFormatter(logging.Formatter(fmt='%(asctime)s  %(levelname)s  %(message)s',
                                        datefmt='%Y-%m-%d %H:%M:%S'))
log.addHandler(log_handler)
log.setLevel(logging.INFO)

ENDPOINT = os.getenv('---')
REGION_NAME = os.getenv('---')
PORT = os.getenv('---')

# NOTE: check/log env vars
log.info("***values of 1] ?={0} 2] ?={1} 3] ?={2}".format(???, ???, ???))

# ---------------------------------------------------------------------------------------------

def default_event_pyspark_driver_config() -> dict:
    """
    *
    """
    return {
            "jobDriver": {
                    "sparkSubmitJobDriver": {
                        "entryPoint": ???,
                        "entryPointArguments": None,
                        "sparkSubmitParameters": """"--conf spark.sql.sources.partitionOverwriteMode=dynamic  \
                                                  --conf spark.executor.instances=1 \
                                                  --conf spark.executor.memory=3G
                                                  --conf spark.driver.memory=3G \
                                                  --conf spark.executor.cores=1 \
                                                  --conf spark.authenticate=false \
                                                  --conf spark.shuffle.service.enabled=false \
                                                  --conf spark.network.crypto.enabled=false \
                                                  --conf spark.authenticate.enableSaslEncryption=false"""
                    }
                }
            }

def main(event_param, context_param=None):

# ---------------------------------------------------------------------------------------------

if __name__ == "__main__":
    main(event, context)
