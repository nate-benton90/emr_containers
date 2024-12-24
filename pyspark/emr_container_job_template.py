import re
import sys
import boto3
import logging
import argparse
import random
import json
import threading
import signal

# 
from pyspark.sql import SparkSession
from random import random
# 

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

def calculate_pi(n_points):
    def is_inside_circle(x, y):
        return x**2 + y**2 <= 1

    points = [(random(), random()) for _ in range(n_points)]
    inside_circle = sum(is_inside_circle(x, y) for x, y in points)

    return 4 * inside_circle / n_points

if __name__ == "__main__":
    spark = SparkSession.builder.appName("CalculatePi").getOrCreate()

    n_points = 1000000  # Adjust as needed
    partitions = 4  # Adjust as needed

    rdd = spark.sparkContext.parallelize(range(n_points), partitions)
    pi_estimate = rdd.map(lambda _: calculate_pi(1)).reduce(lambda a, b: a + b) / partitions

    print("Pi is roughly", pi_estimate)

    spark.stop()
