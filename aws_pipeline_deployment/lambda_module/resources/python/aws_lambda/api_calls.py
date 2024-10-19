import pandas as pd
import requests
import json
import logging
import boto3
import random
import string
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)


class ApiDataCapture:

    def __init__(self):
        self.client = boto3.client('s3')
        self.resource = boto3.resource('s3')
        self.retry_calls = 1000
        self.bucket = os.environ['bucket']
        self.key = os.environ['key']

    def set_page_calls(self):
        try:
            for i in range(0, self.retry_calls):
                if i>=1:
                    pagination = i *  10000
                else:
                    pagination = i

                yield pagination
        except Exception as e:
            logger.error(f'please review the api call or bucket configuration:{e}')


    def get_api_pagination_calls(self):
        try:
            
            for pagination in  self.set_page_calls():
                api_call = f'https://data.sfgov.org/resource/wr8u-xric.json?$limit=10000&$offset={pagination}'
                resp = requests.get(api_call)
                df = pd.DataFrame(resp.json())
                if len(df) != 0:
                    file = "fire_incident_" + "".join([random.choice(string.hexdigits) for i in range(0, 32)]) + ".json"
                    json_file = df.to_json(orient='records', lines=False, indent=4)
                    self.resource.Object(self.bucket, "fire_incidents/" + file).put(Body=json_file,
                                                                            ServerSideEncryption='aws:kms',
                                                                            SSEKMSKeyId=self.key)
                else:
                    break
        except Exception as e:
            logger.error(f'please review the pagination configuration:{e}')

