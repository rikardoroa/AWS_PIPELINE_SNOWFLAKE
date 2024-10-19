# loading libraries
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.conf import SparkConf
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from pyspark.sql.functions import *
from pyspark.sql import SparkSession
import os
import boto3
from botocore.exceptions import ClientError
from py4j.java_gateway import java_import
from pyspark.sql.types import *
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()
# passing environment variables arguments
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'bucket', 'folder', 'kmskey','target_bucket'])

class CreateIncidentsData:
    # init variables and arguments
    def __init__(self):
        self.bucket = args['bucket']
        self.prefix = args['folder']
        self.kmskey = args['kmskey']
        self.target_bucket = args['target_bucket']
        self.spark_session = SparkSession.builder \
            .config('spark.executor.memory', '8g') \
            .config('spark.driver.memory', '8g') \
            .config('spark.dynamicAllocation.enabled', 'true') \
            .config('spark.dynamicAllocation.shuffleTracking.enabled', 'true') \
            .config('spark.executor.cores', 2) \
            .config('spark.hadoop.fs.s3a.server-side-encryption-algorithm', 'SSE-KMS') \
            .config('spark.hadoop.fs.s3.enableServerSideEncryption', 'true') \
            .config('spark.hadoop.fs.s3.serverSideEncryption.kms.keyId', self.kmskey) \
            .appName("CreateIncidentsData") \
            .getOrCreate()
        self.sparkcontext = self.spark_session.sparkContext
        self.client = boto3.client('s3')
        self.path = "".join(['s3://', self.bucket, '/', self.prefix])
        self.resource = boto3.resource('s3')
        
        
        
    def load_files(self):
        # iterating through the bucket to get files
        paginator = self.client.get_paginator('list_objects_v2')
        page_iterator = paginator.paginate(Bucket=self.bucket)
        for page in page_iterator:
            for file in page['Contents']:
                parent_file = file.get('Key').split('/')[-1]
                dataset = self.spark_session.read.format('json'). \
                option('multiline', 'true'). \
                option('header', 'true'). \
                option('inferSchema', 'true').load("".join([self.path,parent_file ]))
                yield dataset
                
                
    def get_files(self):
        key = "incidentsdata.json"
        path = "".join(['s3://', self.target_bucket,'/', 'incidents/'])
        parent_df = list(self.load_files())
        # joining all the datasets in one single dataframe
        if parent_df:
            parent_dataset = parent_df[0]
            for child_df in parent_df[1:]:
                parent_dataset = parent_dataset.unionByName(child_df, allowMissingColumns=True)
            parent_dataset.coalesce(1).write.format("json").mode("overwrite").option("path",path).save()

        # getting the final file for renaming    
        objects = self.client.list_objects_v2(Bucket=self.target_bucket,Prefix='incidents/')
        file = [file['Key'] for file in objects.get('Contents')][-1]
    
        copy_source = {
            'Bucket': self.target_bucket,
            'Key': file
        }
        # copying the file with new name
        destination_bucket = self.target_bucket
        destination_key = "".join(['incidents/' , key])
        self.resource.meta.client.copy(copy_source, destination_bucket, destination_key)
        # deleting old file
        self.client.delete_object(Bucket=self.target_bucket, Key=file)
        
        # deleting old files from the origin
        bucket = self.resource.Bucket(self.bucket)
        objects = bucket.objects.filter(Prefix = 'fire_incidents/')
        objects_to_delete = [{'Key': file.key} for file in objects]

        if objects_to_delete:
            self.resource.meta.client.delete_objects(Bucket=self.bucket, Delete={'Objects': objects_to_delete})
            
            
        
if __name__ == "__main__":
    load_data = CreateIncidentsData()
    load_data.load_files()
    load_data.get_files()