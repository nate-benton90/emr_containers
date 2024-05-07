import re
import sys
import boto3
import logging
import argparse
import random
import json
import threading
import signal

from botocore.config import Config
from time import sleep, time
from datetime import datetime, timedelta, date
from pyspark.conf import SparkConf
from pyspark.sql.functions import lit
from pyspark.sql.utils import AnalysisException
from pyspark.sql import SparkSession
from pyspark.sql.functions import lower, to_json, struct

# --------------------------------------------------------------------------------------------------------------

# NOTE: config logger and argparse setup while printing to log
log = logging.getLogger(__name__)
log_handler = logging.StreamHandler()
log_handler.setFormatter(logging.Formatter(fmt='%(asctime)s  %(levelname)s  %(message)s',
                                            datefmt='%Y-%m-%d %H:%M:%S'))
log.addHandler(log_handler)
log.setLevel(logging.INFO)
log.info('***logger initialized...')

parser = argparse.ArgumentParser(description='---', add_help=True)
parser.add_argument("--foo", type=str, help="---")
parser.add_argument("--bar", type=str, help="---")
parser.add_argument("--what", type=str, help="---")
args = parser.parse_args()

log.info(f'---: {args.foo}')
log.info(f'---: {args.bar}')
log.info(f'---: {args.what}')
log.info("---")

# --------------------------------------------------------------------------------------------------------------

if __name__ == "__main__":
    main()
